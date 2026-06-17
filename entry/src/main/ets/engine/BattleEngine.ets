// engine/BattleEngine.ets
import { BattleHero, Position, Skill, getSkillById, BOARD_ROWS, BOARD_COLS } from '../model/GameData'

export interface BattleResult {
  playerHeroes: BattleHero[]
  enemyHeroes: BattleHero[]
  isWin: boolean
  logs: string[]
}

export class BattleEngine {
  private playerHeroes: BattleHero[]
  private enemyHeroes: BattleHero[]
  private logs: string[] = []
  private onUpdate: (p: BattleHero[], e: BattleHero[]) => void

  constructor(
    player: BattleHero[],
    enemy: BattleHero[],
    onUpdate: (p: BattleHero[], e: BattleHero[]) => void
  ) {
    this.playerHeroes = player
    this.enemyHeroes = enemy
    this.onUpdate = onUpdate
  }

  // 找到最近的敌方棋子
  private findNearestEnemy(hero: BattleHero, enemies: BattleHero[]): BattleHero | null {
    let nearest: BattleHero | null = null
    let minDist = 9999
    for (let e of enemies) {
      if (!e.isAlive || !e.position || !hero.position) continue
      let dist = Math.abs(hero.position.row - e.position.row) +
      Math.abs(hero.position.col - e.position.col)
      if (dist < minDist) {
        minDist = dist
        nearest = e
      }
    }
    return nearest
  }

  // 检查指定格子是否被任何存活棋子占用
  private isCellOccupied(row: number, col: number, excludeHero?: BattleHero): boolean {
    // 检查我方棋子
    for (let h of this.playerHeroes) {
      if (h === excludeHero || !h.isAlive || !h.position) continue
      if (h.position.row === row && h.position.col === col) return true
    }
    // 检查敌方棋子
    for (let h of this.enemyHeroes) {
      if (h === excludeHero || !h.isAlive || !h.position) continue
      if (h.position.row === row && h.position.col === col) return true
    }
    return false
  }

  // 智能移动逻辑（区分近战和远程，永不重叠）
  private moveToward(hero: BattleHero, target: BattleHero): boolean {
    if (!hero.position || !target.position) return false

    const currentDist = Math.abs(hero.position.row - target.position.row) +
    Math.abs(hero.position.col - target.position.col)

    // 远程单位：如果已经在攻击范围内，不移动
    if (hero.attackRange > 1 && currentDist <= hero.attackRange) {
      return false
    }

    // 计算移动方向
    let dr = target.position.row - hero.position.row
    let dc = target.position.col - hero.position.col

    // 优先向距离差更大的方向移动
    let newRow = hero.position.row
    let newCol = hero.position.col

    if (Math.abs(dr) >= Math.abs(dc)) {
      newRow += dr > 0 ? 1 : dr < 0 ? -1 : 0
    } else {
      newCol += dc > 0 ? 1 : dc < 0 ? -1 : 0
    }

    // 边界检查
    if (newRow < 0 || newRow >= BOARD_ROWS || newCol < 0 || newCol >= BOARD_COLS) {
      // 如果主方向不可行，尝试另一个方向
      if (Math.abs(dr) >= Math.abs(dc)) {
        newRow = hero.position.row
        newCol += dc > 0 ? 1 : dc < 0 ? -1 : 0
      } else {
        newCol = hero.position.col
        newRow += dr > 0 ? 1 : dr < 0 ? -1 : 0
      }
      // 再次检查边界
      if (newRow < 0 || newRow >= BOARD_ROWS || newCol < 0 || newCol >= BOARD_COLS) {
        return false
      }
    }

    // 近战单位特殊处理：不能走到目标所在的格子
    if (hero.attackRange === 1) {
      // 如果目标格子就是敌方棋子本身，不移动
      if (newRow === target.position.row && newCol === target.position.col) {
        return false
      }
    }

    // 检查目标格子是否被占用
    if (this.isCellOccupied(newRow, newCol, hero)) {
      // 尝试寻找相邻的空格子（只对近战单位）
      if (hero.attackRange === 1 && currentDist <= 2) {
        // 检查目标周围的8个格子
        const directions = [
          [-1, -1], [-1, 0], [-1, 1],
          [0, -1], [0, 1],
          [1, -1], [1, 0], [1, 1]
        ]
        // ✅ 修复：不使用解构赋值，改用普通循环
        for (let i = 0; i < directions.length; i++) {
          const dRow = directions[i][0]
          const dCol = directions[i][1]
          const testRow = target.position.row + dRow
          const testCol = target.position.col + dCol
          if (testRow >= 0 && testRow < BOARD_ROWS &&
            testCol >= 0 && testCol < BOARD_COLS &&
            !this.isCellOccupied(testRow, testCol, hero)) {
            // 找到可用的相邻格子，移动过去
            hero.position.row = testRow
            hero.position.col = testCol
            return true
          }
        }
        // 周围都被占满了，无法移动
        return false
      }
      return false
    }

    // 所有检查通过，执行移动
    hero.position.row = newRow
    hero.position.col = newCol
    return true
  }

  private calculateDamage(attacker: BattleHero, defender: BattleHero, skill?: Skill): number {
    let damage = 0
    if (skill) {
      damage = skill.damage * attacker.star
      if (skill.damageType === 'magic') {
        damage = damage * (100 / (100 + defender.magicResist))
      }
    } else {
      damage = attacker.attack * attacker.star
      damage = damage * (100 / (100 + defender.defense))
    }
    return Math.floor(damage)
  }

  private async attack(attacker: BattleHero, defender: BattleHero): Promise<void> {
    attacker.isAttacking = true
    this.onUpdate(this.copyHeroes(this.playerHeroes), this.copyHeroes(this.enemyHeroes))
    await this.sleep(300)

    let skill = getSkillById(attacker.skillId)
    let damage = 0
    if (skill && attacker.currentMana >= skill.manaCost) {
      attacker.isCasting = true
      attacker.currentMana = 0
      attacker.skillEffect = 8
      damage = this.calculateDamage(attacker, defender, skill)
      this.logs.push(`${attacker.name} 释放 ${skill.name} 造成 ${damage} 点伤害`)
    } else {
      damage = this.calculateDamage(attacker, defender)
      attacker.currentMana += 10
      if (attacker.currentMana > attacker.maxMana) {
        attacker.currentMana = attacker.maxMana
      }
    }

    defender.currentHealth -= damage
    defender.damageFlash = 5
    defender.lastDamage = damage

    if (defender.currentHealth <= 0) {
      defender.currentHealth = 0
      defender.isAlive = false
      this.logs.push(`${defender.name} 被击败`)
    }

    attacker.isAttacking = false
    attacker.isCasting = false
    this.onUpdate(this.copyHeroes(this.playerHeroes), this.copyHeroes(this.enemyHeroes))
    await this.sleep(200)
  }

  private copyHeroes(heroes: BattleHero[]): BattleHero[] {
    let copy: BattleHero[] = []
    for (let h of heroes) {
      copy.push(h)
    }
    return copy
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  private updateEffects(heroes: BattleHero[]): void {
    for (let h of heroes) {
      if (h.damageFlash > 0) {
        h.damageFlash--
      }
      if (h.skillEffect > 0) {
        h.skillEffect--
      }
      if (h.lastDamage > 0 && h.damageFlash <= 0) {
        h.lastDamage = 0
      }
    }
  }

  async startBattle(): Promise<BattleResult> {
    this.logs.push('=== 战斗开始 ===')
    let round = 0
    while (round < 100) {
      round++
      this.updateEffects(this.playerHeroes)
      this.updateEffects(this.enemyHeroes)
      let hasAction = false

      // 我方棋子行动
      for (let i = 0; i < this.playerHeroes.length; i++) {
        let hero = this.playerHeroes[i]
        if (!hero.isAlive || !hero.position) continue
        let target = this.findNearestEnemy(hero, this.enemyHeroes)
        if (!target || !target.position) break

        let dist = Math.abs(hero.position.row - target.position.row) +
        Math.abs(hero.position.col - target.position.col)

        if (dist <= hero.attackRange) {
          await this.attack(hero, target)
          hasAction = true
        } else {
          if (this.moveToward(hero, target)) {
            hasAction = true
          }
        }
      }

      // 敌方棋子行动
      for (let i = 0; i < this.enemyHeroes.length; i++) {
        let hero = this.enemyHeroes[i]
        if (!hero.isAlive || !hero.position) continue
        let target = this.findNearestEnemy(hero, this.playerHeroes)
        if (!target || !target.position) break

        let dist = Math.abs(hero.position.row - target.position.row) +
        Math.abs(hero.position.col - target.position.col)

        if (dist <= hero.attackRange) {
          await this.attack(hero, target)
          hasAction = true
        } else {
          if (this.moveToward(hero, target)) {
            hasAction = true
          }
        }
      }

      // 检查战斗是否结束
      let playerAlive = this.playerHeroes.filter(h => h.isAlive).length
      let enemyAlive = this.enemyHeroes.filter(h => h.isAlive).length

      if (playerAlive === 0 || enemyAlive === 0) {
        break
      }

      if (hasAction) {
        await this.sleep(400)
      }
    }

    let isWin = this.enemyHeroes.filter(h => h.isAlive).length === 0
    this.logs.push(isWin ? '=== 战斗胜利 ===' : '=== 战斗失败 ===')
    return {
      playerHeroes: this.playerHeroes,
      enemyHeroes: this.enemyHeroes,
      isWin: isWin,
      logs: this.logs
    }
  }
}
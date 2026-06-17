// components/BattleCellComp.ets
import { BattleHero, CELL_SIZE, AVATAR_SIZE, Position } from '../model/GameData'
import { getSkillById } from '../model/GameData'

@Component
export struct BattleCellComp {
  @Prop hero: BattleHero | null = null
  @Prop isPlayer: boolean = false

  // 平滑移动动画状态
  @State private animOffsetX: number = 0
  @State private animOffsetY: number = 0
  private lastPosition: Position | null = null

  // 监听棋子位置变化，自动触发移动动画
  aboutToUpdate(): void {
    if (this.hero && this.hero.position && this.lastPosition) {
      const dx = this.hero.position.col - this.lastPosition.col
      const dy = this.hero.position.row - this.lastPosition.row

      if (dx !== 0 || dy !== 0) {
        // 从反方向开始动画，模拟平滑移动
        this.animOffsetX = -dx * CELL_SIZE
        this.animOffsetY = -dy * CELL_SIZE

        // 300ms平滑过渡到目标位置
        animateTo({
          duration: 300,
          curve: Curve.EaseInOut
        }, () => {
          this.animOffsetX = 0
          this.animOffsetY = 0
        })
      }
    }

    // 更新最后记录的位置
    if (this.hero && this.hero.position) {
      this.lastPosition = {
        row: this.hero.position.row,
        col: this.hero.position.col
      }
    } else {
      this.lastPosition = null
    }
  }

  getShakeX(): number {
    if (!this.hero || this.hero.damageFlash <= 0) return 0
    return (this.hero.damageFlash % 2 === 0) ? 6 : -6
  }

  getAttackX(): number {
    if (!this.hero || !this.hero.isAttacking) return 0
    return this.isPlayer ? 15 : -15
  }

  getAttackY(): number {
    if (!this.hero || !this.hero.isAttacking) return 0
    return -8
  }

  getSkillScale(): number {
    if (!this.hero || this.hero.skillEffect <= 0) return 0
    return 1 + (this.hero.skillEffect / 8) * 0.5
  }

  getSkillOpacity(): number {
    if (!this.hero || this.hero.skillEffect <= 0) return 0
    return this.hero.skillEffect / 8
  }

  getStars(count: number): number[] {
    let arr: number[] = []
    for (let i = 0; i < count; i++) {
      arr.push(i)
    }
    return arr
  }

  private get currentSkill() {
    if (!this.hero) return null
    return getSkillById(this.hero.skillId)
  }

  private get skillBackgroundColor() {
    return this.currentSkill ? this.currentSkill.skillColor + '30' : '#FFD70030'
  }

  private get skillIcon() {
    return this.currentSkill ? this.currentSkill.skillIcon : '⚡'
  }

  build() {
    Stack() {
      // 技能特效层
      if (this.hero && this.hero.skillEffect > 0) {
        Stack() {
          // 外圈大光环
          Column()
            .width(CELL_SIZE * 1.5)
            .height(CELL_SIZE * 1.5)
            .backgroundColor(this.skillBackgroundColor)
            .borderRadius(CELL_SIZE * 0.75)
            .scale({ x: this.getSkillScale(), y: this.getSkillScale() })
            .opacity(this.getSkillOpacity())
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
          // 技能图标旋转
          Text(this.skillIcon)
            .fontSize(24)
            .rotate({ angle: (8 - this.hero.skillEffect) * 45 })
            .opacity(this.getSkillOpacity())
            .animation({
              duration: 100,
              curve: Curve.Linear
            })
        }
        .width(CELL_SIZE * 1.5)
        .height(CELL_SIZE * 1.5)
        .align(Alignment.Center)
      }

      // 棋子主体
      if (this.hero && this.hero.isAlive) {
        Column({ space: 2 }) {
          Stack() {
            // 施法光环
            if (this.hero.isCasting) {
              Column()
                .width(AVATAR_SIZE + 10)
                .height(AVATAR_SIZE + 10)
                .border({ width: 3, color: '#FFD700' })
                .borderRadius((AVATAR_SIZE + 10) / 2)
                .shadow({ radius: 20, color: '#FFD700' })
                .opacity(0.9)
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
            }
            // 头像本体
            Text(this.hero.icon)
              .fontSize(AVATAR_SIZE * 0.6)
              .width(AVATAR_SIZE)
              .height(AVATAR_SIZE)
              .backgroundColor(this.hero.color)
              .borderRadius(AVATAR_SIZE / 2)
              .textAlign(TextAlign.Center)
              .shadow({ radius: 6, color: this.hero.color + '80' })
              .scale({
                x: this.hero.isAttacking ? 1.4 : 1.0,
                y: this.hero.isAttacking ? 1.4 : 1.0
              })
              .translate({ x: this.getAttackX(), y: this.getAttackY() })
              .animation({
                duration: 150,
                curve: Curve.EaseInOut
              })
            // 攻击特效：武器图标
            if (this.hero.isAttacking) {
              Text(this.isPlayer ? '⚔️' : '🗡️')
                .fontSize(20)
                .position({
                  x: this.isPlayer ? AVATAR_SIZE + 5 : -20,
                  y: -10
                })
                .rotate({ angle: this.isPlayer ? -30 : 30 })
                .opacity(0.9)
                .animation({
                  duration: 150,
                  curve: Curve.EaseOut
                })
            }
            // 攻击白光
            if (this.hero.isAttacking) {
              Column()
                .width(AVATAR_SIZE)
                .height(AVATAR_SIZE)
                .backgroundColor('#FFFFFF')
                .opacity(0.5)
                .borderRadius(AVATAR_SIZE / 2)
            }
            // 受击红色爆闪
            if (this.hero.damageFlash > 0) {
              Column()
                .width(AVATAR_SIZE)
                .height(AVATAR_SIZE)
                .backgroundColor('#FF0000')
                .opacity(Math.min(this.hero.damageFlash / 5, 0.7))
                .borderRadius(AVATAR_SIZE / 2)
            }
          }
          .width(AVATAR_SIZE + 10)
          .height(AVATAR_SIZE + 10)
          // 星级
          Row({ space: 2 }) {
            ForEach(this.getStars(this.hero.star), (_: number) => {
              Text('⭐')
                .fontSize(9)
                .fontColor('#FFD700')
                .shadow({ radius: 2, color: '#FFD700' })
            })
          }
          // 血条
          Stack() {
            Row()
              .width(56)
              .height(6)
              .backgroundColor('#333')
              .borderRadius(3)
            Row()
              .width(56 * (this.hero.currentHealth / this.hero.maxHealth))
              .height(6)
              .backgroundColor(this.hero.currentHealth / this.hero.maxHealth > 0.3 ? '#4CAF50' : '#F44336')
              .borderRadius(3)
          }
          .width(56)
          .height(6)
          // 蓝条
          if (this.hero.maxMana > 0) {
            Stack() {
              Row()
                .width(56)
                .height(4)
                .backgroundColor('#333')
                .borderRadius(2)
              Row()
                .width(56 * (this.hero.currentMana / this.hero.maxMana))
                .height(4)
                .backgroundColor('#2196F3')
                .borderRadius(2)
            }
            .width(56)
            .height(4)
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        // 合并受击抖动和平滑移动动画
        .translate({ x: this.getShakeX() + this.animOffsetX, y: this.animOffsetY })
      } else if (this.hero && !this.hero.isAlive) {
        // 死亡特效
        Column() {
          Text(this.hero.icon)
            .fontSize(24)
            .width(AVATAR_SIZE)
            .height(AVATAR_SIZE)
            .backgroundColor('#666')
            .borderRadius(AVATAR_SIZE / 2)
            .textAlign(TextAlign.Center)
            .opacity(0.3)
            .grayscale(1)
          Text('💀')
            .fontSize(16)
            .position({ x: 10, y: -5 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // 伤害飘字
      if (this.hero && this.hero.lastDamage > 0) {
        Text(`-${this.hero.lastDamage}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF0000')
          .position({ x: 18, y: -12 })
          .translate({ y: -12 })
          .shadow({ radius: 2, color: '#FF0000' })
          .animation({
            duration: 600,
            curve: Curve.EaseOut
          })
      }
    }
    // ✅ 核心修改：从固定CELL_SIZE改为100%自适应
    .width('100%')
    .height('100%')
  }
}
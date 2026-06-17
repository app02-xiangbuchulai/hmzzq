// pages/Index.ets
import { Hero, Position, BattleHero, HERO_POOL, BOARD_ROWS, BOARD_COLS, PLAYER_ROWS, INITIAL_GOLD, INITIAL_HEALTH, createBattleHero, calculateSellPrice, CELL_SIZE } from '../model/GameData'
import { BattleEngine, BattleResult } from '../engine/BattleEngine'
import { ChessBoard } from '../components/ChessBoard'
import { ShopPanel } from '../components/ShopPanel'
import { BattleInfo } from '../components/BattleInfo'
import { HeroCard } from '../components/HeroCard'
import { BattleCellComp } from '../components/BattleCellComp'

interface BattleCellInfo {
  hero: BattleHero | null
  isPlayer: boolean
}

@Entry
@Component
struct AutoChessGame {
  @State boardState: (Hero | null)[][] = this.initBoard()
  @State benchHeroes: Hero[] = []
  @State playerGold: number = INITIAL_GOLD
  @State playerHealth: number = INITIAL_HEALTH
  @State round: number = 1
  @State battleState: string = '准备阶段'
  @State selectedBenchIndex: number = -1
  @State isPlacingFromBench: boolean = false
  @State selectedBoardHero: Position | null = null
  @State battlePlayerHeroes: BattleHero[] = []
  @State battleEnemyHeroes: BattleHero[] = []
  @State isBattling: boolean = false
  @State battleLogs: string[] = []
  @State showBattleLog: boolean = false
  @State showHeroDetail: boolean = false
  @State detailHero: Hero = HERO_POOL[0]
  @State timer: number = 30
  private timerId: number = -1
  @State isBenchExpanded: boolean = true
  @State isShopExpanded: boolean = true
  @State showResultDialog: boolean = false
  @State lastBattleResult: boolean = false
  @State battleReward: number = 0

  aboutToAppear(): void {
    this.startTimer()
  }

  aboutToDisappear(): void {
    this.clearTimer()
  }

  private startTimer(): void {
    this.clearTimer()
    this.timer = 30
    this.tickTimer()
  }

  private tickTimer(): void {
    if (this.timer > 0 && this.battleState === '准备阶段') {
      this.timer--
      this.timerId = setTimeout(() => {
        this.tickTimer()
      }, 1000)
    } else if (this.timer <= 0 && this.battleState === '准备阶段' && !this.isBattling) {
      this.handleStartBattle()
    }
  }

  private clearTimer(): void {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)
      this.timerId = -1
    }
  }

  initBoard(): (Hero | null)[][] {
    let board: (Hero | null)[][] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      let row: (Hero | null)[] = []
      for (let j = 0; j < BOARD_COLS; j++) {
        row.push(null)
      }
      board.push(row)
    }
    return board
  }

  getBattleHeroAt(row: number, col: number): BattleCellInfo {
    for (let h of this.battlePlayerHeroes) {
      if (h.isAlive && h.position && h.position.row === row && h.position.col === col) {
        return { hero: h, isPlayer: true }
      }
    }
    for (let h of this.battleEnemyHeroes) {
      if (h.isAlive && h.position && h.position.row === row && h.position.col === col) {
        return { hero: h, isPlayer: false }
      }
    }
    return { hero: null, isPlayer: false }
  }

  handleBuyHero(hero: Hero, cost: number): void {
    if (this.playerGold >= cost && this.benchHeroes.length < 9) {
      this.playerGold -= cost
      let newHero: Hero = {
        id: hero.id,
        name: hero.name,
        cost: hero.cost,
        icon: hero.icon,
        skillIcon: hero.skillIcon,
        color: hero.color,
        health: hero.health,
        maxHealth: hero.maxHealth,
        currentHealth: hero.maxHealth,
        attack: hero.attack,
        defense: hero.defense,
        magicResist: hero.magicResist,
        attackSpeed: hero.attackSpeed,
        attackRange: hero.attackRange,
        skillId: hero.skillId,
        origin: hero.origin,
        class: hero.class,
        currentMana: 0,
        maxMana: hero.maxMana,
        star: 1,
        position: undefined
      }
      this.benchHeroes = this.benchHeroes.concat([newHero])
    }
  }

  handleSellBenchHero(index: number): void {
    if (index < 0 || index >= this.benchHeroes.length) return
    let hero = this.benchHeroes[index]
    let price = calculateSellPrice(hero)
    this.playerGold += price
    let newBench: Hero[] = []
    for (let i = 0; i < this.benchHeroes.length; i++) {
      if (i !== index) {
        newBench.push(this.benchHeroes[i])
      }
    }
    this.benchHeroes = newBench
    if (this.selectedBenchIndex === index) {
      this.selectedBenchIndex = -1
      this.isPlacingFromBench = false
    }
  }

  handleSellBoardHero(row: number, col: number): void {
    let hero = this.boardState[row][col]
    if (!hero) return
    let price = calculateSellPrice(hero)
    this.playerGold += price
    let newBoard: (Hero | null)[][] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      let newRow: (Hero | null)[] = []
      for (let j = 0; j < BOARD_COLS; j++) {
        if (i === row && j === col) {
          newRow.push(null)
        } else {
          newRow.push(this.boardState[i][j])
        }
      }
      newBoard.push(newRow)
    }
    this.boardState = newBoard
    this.selectedBoardHero = null
  }

  handleBenchSelect(index: number): void {
    if (this.selectedBenchIndex === index) {
      this.selectedBenchIndex = -1
      this.isPlacingFromBench = false
    } else {
      this.selectedBenchIndex = index
      this.isPlacingFromBench = true
      this.selectedBoardHero = null
    }
  }

  handlePlaceToBoard(row: number, col: number): void {
    if (!this.isPlacingFromBench || this.selectedBenchIndex < 0) return
    if (row < BOARD_ROWS - PLAYER_ROWS) return
    if (this.boardState[row][col] !== null) return

    let hero = this.benchHeroes[this.selectedBenchIndex]
    hero.position = { row: row, col: col } as Position

    let newBoard: (Hero | null)[][] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      let newRow: (Hero | null)[] = []
      for (let j = 0; j < BOARD_COLS; j++) {
        if (i === row && j === col) {
          newRow.push(hero)
        } else {
          newRow.push(this.boardState[i][j])
        }
      }
      newBoard.push(newRow)
    }
    this.boardState = newBoard

    let newBench: Hero[] = []
    for (let i = 0; i < this.benchHeroes.length; i++) {
      if (i !== this.selectedBenchIndex) {
        newBench.push(this.benchHeroes[i])
      }
    }
    this.benchHeroes = newBench
    this.selectedBenchIndex = -1
    this.isPlacingFromBench = false
  }

  handleBoardSelect(row: number, col: number): void {
    let hero = this.boardState[row][col]
    if (hero) {
      this.selectedBoardHero = { row: row, col: col } as Position
      this.selectedBenchIndex = -1
      this.isPlacingFromBench = false
      this.detailHero = hero
      this.showHeroDetail = true
    } else if (this.selectedBoardHero) {
      this.handleHeroMove(this.selectedBoardHero, { row: row, col: col } as Position)
      this.selectedBoardHero = null
    }
  }

  handleHeroMove(from: Position, to: Position): void {
    let hero = this.boardState[from.row][from.col]
    if (!hero || this.boardState[to.row][to.col] !== null) return
    if (to.row < BOARD_ROWS - PLAYER_ROWS) return

    let newBoard: (Hero | null)[][] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      let newRow: (Hero | null)[] = []
      for (let j = 0; j < BOARD_COLS; j++) {
        if (i === to.row && j === to.col) {
          newRow.push(hero)
        } else if (i === from.row && j === from.col) {
          newRow.push(null)
        } else {
          newRow.push(this.boardState[i][j])
        }
      }
      newBoard.push(newRow)
    }
    hero.position = to
    this.boardState = newBoard
  }

  async handleStartBattle(): Promise<void> {
    this.clearTimer()
    this.battleState = '战斗进行中'
    this.isBattling = true
    this.showResultDialog = false
    this.showBattleLog = false

    let playerBattleHeroes: BattleHero[] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      for (let j = 0; j < BOARD_COLS; j++) {
        let hero = this.boardState[i][j]
        if (hero && i >= BOARD_ROWS - PLAYER_ROWS) {
          let battleHero = createBattleHero(hero)
          battleHero.position = { row: i, col: j } as Position
          playerBattleHeroes.push(battleHero)
        }
      }
    }

    let enemyBattleHeroes: BattleHero[] = []
    let enemyPool = [HERO_POOL[0], HERO_POOL[1], HERO_POOL[2]]
    for (let i = 0; i < 3; i++) {
      let e = createBattleHero(enemyPool[i])
      e.position = { row: Math.floor(Math.random() * 2), col: Math.floor(Math.random() * BOARD_COLS) } as Position
      enemyBattleHeroes.push(e)
    }

    this.battlePlayerHeroes = playerBattleHeroes
    this.battleEnemyHeroes = enemyBattleHeroes

    let engine = new BattleEngine(
      playerBattleHeroes,
      enemyBattleHeroes,
      (p, e) => {
        this.battlePlayerHeroes = p
        this.battleEnemyHeroes = e
      }
    )

    let result: BattleResult = await engine.startBattle()
    this.battleLogs = result.logs

    if (result.isWin) {
      this.battleReward = 5 + this.round
      this.playerGold += this.battleReward
    } else {
      this.battleReward = 20
      this.playerHealth -= 20
    }

    this.isBattling = false
    this.battleState = '战斗结束'
    this.lastBattleResult = result.isWin

    setTimeout(() => {
      this.showResultDialog = true
    }, 300)
  }

  handleNextRound(): void {
    this.round++
    this.battleState = '准备阶段'
    this.playerGold += 5
    this.battlePlayerHeroes = []
    this.battleEnemyHeroes = []
    this.battleLogs = []
    this.showBattleLog = false
    this.showResultDialog = false
    this.startTimer()
  }

  handleCloseResultDialog(): void {
    this.showResultDialog = false
    this.showBattleLog = true
  }

  getRows(): number[] {
    let arr: number[] = []
    for (let i = 0; i < BOARD_ROWS; i++) {
      arr.push(i)
    }
    return arr
  }

  getCols(): number[] {
    let arr: number[] = []
    for (let i = 0; i < BOARD_COLS; i++) {
      arr.push(i)
    }
    return arr
  }

  getStars(count: number): number[] {
    let arr: number[] = []
    for (let i = 0; i < count; i++) {
      arr.push(i)
    }
    return arr
  }

  getLogItems(): string[] {
    let items: string[] = []
    for (let i = 0; i < this.battleLogs.length && i < 50; i++) {
      items.push(this.battleLogs[i])
    }
    return items
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 16 }) {
          Text('🎮 自走棋对战')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .margin({ top: 20 })

          BattleInfo({
            round: this.round,
            playerHealth: this.playerHealth,
            enemyHealth: 100,
            battleState: this.battleState,
            timer: this.timer,
            onStartBattle: () => this.handleStartBattle(),
            onNextRound: () => this.handleNextRound()
          })

          if (this.isBattling) {
            this.BattleBoardBuilder()
          } else {
            ChessBoard({
              boardState: this.boardState,
              isPlacingFromBench: this.isPlacingFromBench,
              selectedBoardPos: this.selectedBoardHero,
              isBattlePhase: this.isBattling,
              onHeroMove: (from, to) => this.handleHeroMove(from, to),
              onHeroSelect: (hero, pos) => this.handleBoardSelect(pos.row, pos.col),
              onPlaceHero: (row, col) => this.handlePlaceToBoard(row, col),
              onSellHero: (row, col) => this.handleSellBoardHero(row, col)
            })
          }

          if (!this.isBattling) {
            Column({ space: 10 }) {
              Row({ space: 8 }) {
                Text('🎒 备战席')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text(this.isBenchExpanded ? '▼' : '▲')
                  .fontSize(16)
                  .fontColor('#666')
              }
              .width('100%')
              .onClick(() => this.isBenchExpanded = !this.isBenchExpanded)

              if (this.isBenchExpanded) {
                if (this.isPlacingFromBench) {
                  Text('👆 选择英雄，点击棋盘格子进行放置')
                    .fontSize(13)
                    .fontColor('#FF9800')
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
                List() {
                  ForEach(this.benchHeroes, (hero: Hero, index: number) => {
                    ListItem() {
                      HeroCard({
                        hero: hero,
                        isSelected: this.selectedBenchIndex === index,
                        cardClick: () => this.handleBenchSelect(index),
                        cardLongPress: () => this.handleSellBenchHero(index)
                      })
                    }
                  })
                }
                .width('100%')
                .height(140)
                .listDirection(Axis.Horizontal)
                .padding(10)
                .backgroundColor('#FAFAFA')
                .borderRadius(12)
              }
            }
            .width('100%')
            .padding(10)

            Column({ space: 10 }) {
              Row({ space: 8 }) {
                Text('🏪 商店')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                Text(this.isShopExpanded ? '▼' : '▲')
                  .fontSize(16)
                  .fontColor('#666')
              }
              .width('100%')
              .onClick(() => this.isShopExpanded = !this.isShopExpanded)

              if (this.isShopExpanded) {
                ShopPanel({
                  playerGold: this.playerGold,
                  round: this.round,
                  onBuyHero: (hero: Hero) => this.handleBuyHero(hero, hero.cost),
                  onRefreshShop: () => {
                    if (this.playerGold >= 2) {
                      this.playerGold -= 2
                    }
                  }
                })
              }
            }
            .width('100%')
            .padding(10)
          }

          if (this.showBattleLog && !this.showResultDialog) {
            this.BattleLogBuilder()
          }

          if (this.showHeroDetail && !this.isBattling && !this.showResultDialog) {
            this.HeroDetailDialog()
          }
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#EEE')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)

      if (this.showResultDialog) {
        this.ResultDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ✅ 放大版自适应战斗地图：占满屏幕95%宽度，自动保持7:4比例
  @Builder
  BattleBoardBuilder() {
    Column({ space: 8 }) {
      Text('⚔️ 战斗画面')
        .fontSize(24)
        .fontColor('#F44336')
        .fontWeight(FontWeight.Bold)

      Stack() {
        // 1. 背景贴图：占满整个容器
        Image($r('app.media.battle_board_bg'))
          .width('100%')
          .height('100%')
          .borderRadius(20)
          .shadow({ radius: 12, color: '#20000000' })
          .objectFit(ImageFit.Cover)
          .interpolation(ImageInterpolation.High)

        // 2. 所有棋子：百分比定位，自动适配地图大小
        Stack() {
          ForEach(
            this.battlePlayerHeroes.concat(this.battleEnemyHeroes),
            (hero: BattleHero) => {
              if (hero.isAlive && hero.position) {
                Stack() {
                  BattleCellComp({
                    hero: hero,
                    isPlayer: this.battlePlayerHeroes.includes(hero)
                  })
                }
                .width(`${100 / BOARD_COLS}%`)
                .height(`${100 / BOARD_ROWS}%`)
                .position({
                  x: `${(hero.position.col / BOARD_COLS) * 100}%`,
                  y: `${(hero.position.row / BOARD_ROWS) * 100}%`
                })
              }
            },
            (hero: BattleHero) => hero.id
          )
        }
        .width('100%')
        .height('100%')
      }
      // 核心：地图占屏幕95%宽度，自动保持7:4的棋盘比例
      .width('95%')
      .aspectRatio(BOARD_COLS / BOARD_ROWS)
    }
    .width('100%')
    .padding({ top: 8, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#20000000' })
  }

  @Builder
  BattleLogBuilder() {
    Column({ space: 10 }) {
      Text('📜 战斗日志')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      List() {
        ForEach(this.getLogItems(), (log: string) => {
          ListItem() {
            Text(log)
              .fontSize(13)
              .fontColor('#666')
              .padding(6)
          }
        })
      }
      .width('100%')
      .height(140)
      .backgroundColor('#FAFAFA')
      .borderRadius(12)
      .padding(10)
      Button('✖ 关闭')
        .width(120)
        .height(40)
        .onClick(() => this.showBattleLog = false)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#20000000' })
  }

  @Builder
  HeroDetailDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => this.showHeroDetail = false)

      Column({ space: 14 }) {
        Text(this.detailHero.icon)
          .fontSize(48)
          .width(80)
          .height(80)
          .backgroundColor(this.detailHero.color)
          .borderRadius(20)
          .textAlign(TextAlign.Center)

        Text(this.detailHero.name)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)

        Row({ space: 4 }) {
          ForEach(this.getStars(this.detailHero.star), (_: number) => {
            Text('⭐')
              .fontSize(20)
              .fontColor('#FFD700')
          })
        }

        Column({ space: 10 }) {
          Row({ space: 20 }) {
            Text(`❤️ ${this.detailHero.currentHealth}/${this.detailHero.maxHealth}`)
              .fontSize(16)
            Text(`⚔️ ${this.detailHero.attack}`)
              .fontSize(16)
          }
          Row({ space: 20 }) {
            Text(`🛡️ ${this.detailHero.defense}`)
              .fontSize(16)
            Text(`🔮 ${this.detailHero.magicResist}`)
              .fontSize(16)
          }
          Row({ space: 20 }) {
            Text(`⚡ ${this.detailHero.attackSpeed}`)
              .fontSize(16)
            Text(`🎯 ${this.detailHero.attackRange}`)
              .fontSize(16)
          }
        }

        Row({ space: 10 }) {
          Text('🏷️ 羁绊:')
          ForEach(this.detailHero.origin.concat(this.detailHero.class), (tag: string) => {
            Text(tag)
              .fontColor('#FFF')
              .backgroundColor('#666')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(6)
              .fontSize(14)
          })
        }

        Row({ space: 16 }) {
          Button(`💰 出售 (+${calculateSellPrice(this.detailHero)}金币)`)
            .backgroundColor('#FF9800')
            .height(44)
            .width(160)
            .onClick(() => {
              if (this.selectedBoardHero) {
                this.handleSellBoardHero(this.selectedBoardHero.row, this.selectedBoardHero.col)
                this.showHeroDetail = false
                this.selectedBoardHero = null
              }
            })
          Button('✖ 关闭')
            .backgroundColor('#9E9E9E')
            .height(44)
            .width(100)
            .onClick(() => this.showHeroDetail = false)
        }
      }
      .width(340)
      .padding(28)
      .backgroundColor('#FFF')
      .borderRadius(20)
      .shadow({ radius: 12, color: '#40000000' })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
  }

  @Builder
  ResultDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#CC000000')
        .onClick(() => {})

      Column({ space: 24 }) {
        Text(this.lastBattleResult ? '🎉🏆🎉' : '💔😢💔')
          .fontSize(72)
          .textAlign(TextAlign.Center)

        Text(this.lastBattleResult ? '战斗胜利！' : '战斗失败')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.lastBattleResult ? '#FFD700' : '#F44336')
          .textAlign(TextAlign.Center)

        Column({ space: 12 }) {
          Text(this.lastBattleResult ? `获得 ${this.battleReward} 金币 💰` : '失去 20 生命值 ❤️')
            .fontSize(22)
            .fontColor(this.lastBattleResult ? '#4CAF50' : '#F44336')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
        }
        .padding(15)
        .backgroundColor(this.lastBattleResult ? '#E8F5E9' : '#FFEBEE')
        .borderRadius(16)
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        Text(this.lastBattleResult ? '✨🌟✨' : '☁️💨☁️')
          .fontSize(28)
          .textAlign(TextAlign.Center)

        Column({ space: 12 }) {
          Button('➡️ 下一回合')
            .fontSize(20)
            .height(56)
            .width(200)
            .backgroundColor(this.lastBattleResult ? '#4CAF50' : '#2196F3')
            .shadow({ radius: 10, color: this.lastBattleResult ? '#4CAF5080' : '#2196F380' })
            .onClick(() => this.handleNextRound())

          Button('📜 查看战斗日志')
            .fontSize(16)
            .height(44)
            .width(200)
            .backgroundColor('#9E9E9E')
            .onClick(() => this.handleCloseResultDialog())
        }
      }
      .width(360)
      .padding(35)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 25, color: '#60000000' })
      .alignItems(HorizontalAlign.Center)
      .scale({ x: 1.05, y: 1.05 })
      .animation({
        duration: 400,
        curve: Curve.EaseOut
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
  }
}
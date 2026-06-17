// components/ChessBoard.ets
import { Hero, Position, BOARD_ROWS, BOARD_COLS, PLAYER_ROWS, CELL_SIZE, AVATAR_SIZE } from '../model/GameData'

@Component
struct Cell {
  @Prop hero: Hero | null = null
  @Prop isSelected: boolean = false
  @Prop isPlayerArea: boolean = false
  @Prop isPlaceTarget: boolean = false
  @Prop row: number = 0
  @Prop col: number = 0
  cellClick: () => void = () => {}
  cellLongPress: () => void = () => {}

  getHeroColor(cost: number): ResourceColor {
    switch (cost) {
      case 1: return '#9E9E9E'
      case 2: return '#4CAF50'
      case 3: return '#2196F3'
      case 4: return '#9C27B0'
      case 5: return '#FFD700'
      default: return '#9E9E9E'
    }
  }

  getHealthColor(current: number, max: number): ResourceColor {
    let ratio = current / max
    if (ratio > 0.6) return '#4CAF50'
    if (ratio > 0.3) return '#FF9800'
    return '#F44336'
  }

  getStars(count: number): number[] {
    let arr: number[] = []
    for (let i = 0; i < count; i++) {
      arr.push(i)
    }
    return arr
  }

  build() {
    Stack() {
      Column()
        .width(CELL_SIZE)
        .height(CELL_SIZE)
        .backgroundColor(this.getBackgroundColor())
        .border({
          width: this.isPlaceTarget || this.isSelected ? 3 : 2,
          color: this.getBorderColor()
        })
        .borderRadius(12)
        .shadow({ radius: this.isSelected ? 8 : 2, color: this.getBorderColor() + '40' })

      if (this.hero !== null) {
        Column({ space: 2 }) {
          Text(this.hero.icon)
            .fontSize(24)
            .width(AVATAR_SIZE)
            .height(AVATAR_SIZE)
            .backgroundColor(this.hero.color || this.getHeroColor(this.hero.cost))
            .borderRadius(AVATAR_SIZE / 2)
            .textAlign(TextAlign.Center)
            .shadow({ radius: 4, color: (this.hero.color || '#999') + '60' })

          Row({ space: 2 }) {
            ForEach(this.getStars(this.hero.star || 1), (_: number) => {
              Text('★')
                .fontSize(9)
                .fontColor('#FFD700')
                .shadow({ radius: 1, color: '#FFD700' })
            })
          }

          Stack() {
            Row()
              .width(56)
              .height(6)
              .backgroundColor('#333')
              .borderRadius(3)
            Row()
              .width(56 * ((this.hero.currentHealth || 0) / this.hero.maxHealth))
              .height(6)
              .backgroundColor(this.getHealthColor(this.hero.currentHealth || 0, this.hero.maxHealth))
              .borderRadius(3)
          }
          .width(56)
          .height(6)

          if (this.hero.maxMana !== undefined && this.hero.maxMana > 0) {
            Stack() {
              Row()
                .width(56)
                .height(4)
                .backgroundColor('#333')
                .borderRadius(2)
              Row()
                .width(56 * ((this.hero.currentMana || 0) / this.hero.maxMana))
                .height(4)
                .backgroundColor('#2196F3')
                .borderRadius(2)
            }
            .width(56)
            .height(4)
          }
        }
        .width(CELL_SIZE)
        .height(CELL_SIZE)
        .justifyContent(FlexAlign.Center)
      }

      if (this.isPlaceTarget && this.hero === null) {
        Text('➕')
          .fontSize(36)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
          .opacity(0.8)
      }

      Text(`${this.row},${this.col}`)
        .fontSize(9)
        .fontColor('#999')
        .position({ x: 4, y: 4 })
    }
    .width(CELL_SIZE)
    .height(CELL_SIZE)
    .onClick(() => this.cellClick())
    .gesture(
      LongPressGesture({ duration: 500 })
        .onAction(() => this.cellLongPress())
    )
  }

  getBackgroundColor(): ResourceColor {
    if (this.isSelected) return '#FFF9C4'
    if (this.isPlaceTarget && this.hero === null) return '#C8E6C9'
    if (this.isPlayerArea) return '#E8F5E9'
    return '#FFEBEE'
  }

  getBorderColor(): ResourceColor {
    if (this.isSelected) return '#FF9800'
    if (this.isPlaceTarget && this.hero === null) return '#4CAF50'
    if (this.isPlayerArea) return '#81C784'
    return '#EF9A9A'
  }
}

@Component
export struct ChessBoard {
  @Prop boardState: (Hero | null)[][]
  @Prop isPlacingFromBench: boolean = false
  @Prop selectedBoardPos: Position | null = null
  @Prop isBattlePhase: boolean = false
  onHeroMove: (from: Position, to: Position) => void = () => {}
  onHeroSelect: (hero: Hero, pos: Position) => void = () => {}
  onPlaceHero: (row: number, col: number) => void = () => {}
  onSellHero: (row: number, col: number) => void = () => {}

  isPlayerArea(row: number): boolean {
    return row >= BOARD_ROWS - PLAYER_ROWS
  }

  getHeroSafe(row: number, col: number): Hero | null {
    let rowData = this.boardState[row]
    if (rowData === undefined || rowData === null) return null
    let hero = rowData[col]
    if (hero === undefined || hero === null) return null
    return hero
  }

  build() {
    Column({ space: 4 }) {
      Text('🔴 敌方区域')
        .fontSize(16)
        .fontColor('#F44336')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Center)

      ForEach(this.getRows(), (row: number) => {
        Row({ space: 4 }) {
          ForEach(this.getCols(), (col: number) => {
            Cell({
              hero: this.getHeroSafe(row, col),
              isSelected: this.selectedBoardPos !== null &&
                this.selectedBoardPos.row === row &&
                this.selectedBoardPos.col === col,
              isPlayerArea: this.isPlayerArea(row),
              isPlaceTarget: !this.isBattlePhase && this.isPlacingFromBench && this.isPlayerArea(row) && this.getHeroSafe(row, col) === null,
              row: row,
              col: col,
              cellClick: () => this.handleCellClick(row, col),
              cellLongPress: () => this.handleCellLongPress(row, col)
            })
          })
        }
      })

      Text('🟢 我方区域（点击放置 / 长按出售）')
        .fontSize(16)
        .fontColor('#4CAF50')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#20000000' })
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

  handleCellClick(row: number, col: number): void {
    let hero = this.getHeroSafe(row, col)

    if (this.isPlacingFromBench) {
      if (hero === null && this.isPlayerArea(row)) {
        this.onPlaceHero(row, col)
      }
      return
    }

    if (hero !== null) {
      this.onHeroSelect(hero, { row, col })
    } else if (this.selectedBoardPos !== null) {
      this.onHeroMove(this.selectedBoardPos, { row, col })
    }
  }

  handleCellLongPress(row: number, col: number): void {
    let hero = this.getHeroSafe(row, col)
    if (hero !== null && this.isPlayerArea(row)) {
      this.onSellHero(row, col)
    }
  }
}
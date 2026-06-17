// components/BattleInfo.ets

@Component
export struct BattleInfo {
  @Prop round: number = 1
  @Prop playerHealth: number = 100
  @Prop enemyHealth: number = 100
  @Prop battleState: string = '准备阶段'
  @Prop timer: number = 30
  onStartBattle: () => void = () => {}
  onNextRound: () => void = () => {}

  build() {
    Row({ space: 20 }) {
      Column({ space: 6 }) {
        Text('🛡️ 我方')
          .fontSize(16)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
        Stack() {
          Row()
            .width(120)
            .height(20)
            .backgroundColor('#333')
            .borderRadius(10)
          Row()
            .width(120 * (this.playerHealth / 100))
            .height(20)
            .backgroundColor('#4CAF50')
            .borderRadius(10)
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
          Text(`${this.playerHealth}/100`)
            .fontSize(12)
            .fontColor('#FFF')
            .width(120)
            .textAlign(TextAlign.Center)
        }
        .width(120)
        .height(20)
      }

      Column({ space: 6 }) {
        Text(`⚔️ 第 ${this.round} 回合`)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Text(this.battleState)
          .fontSize(16)
          .fontColor(this.getStateColor())
          .fontWeight(FontWeight.Medium)
        Text(`⏱️ ${this.timer}s`)
          .fontSize(18)
          .fontColor('#FF9800')
          .fontWeight(FontWeight.Bold)

        if (this.battleState === '准备阶段') {
          Button('🔥 开始战斗')
            .fontSize(16)
            .height(44)
            .width(140)
            .backgroundColor('#F44336')
            .shadow({ radius: 6, color: '#F4433640' })
            .onClick(() => this.onStartBattle())
        } else if (this.battleState === '战斗结束') {
          Button('➡️ 下一回合')
            .fontSize(16)
            .height(44)
            .width(140)
            .backgroundColor('#2196F3')
            .shadow({ radius: 6, color: '#2196F340' })
            .onClick(() => this.onNextRound())
        }
      }

      Column({ space: 6 }) {
        Text('⚔️ 敌方')
          .fontSize(16)
          .fontColor('#F44336')
          .fontWeight(FontWeight.Bold)
        Stack() {
          Row()
            .width(120)
            .height(20)
            .backgroundColor('#333')
            .borderRadius(10)
          Row()
            .width(120 * (this.enemyHealth / 100))
            .height(20)
            .backgroundColor('#F44336')
            .borderRadius(10)
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
          Text(`${this.enemyHealth}/100`)
            .fontSize(12)
            .fontColor('#FFF')
            .width(120)
            .textAlign(TextAlign.Center)
        }
        .width(120)
        .height(20)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#20000000' })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  getStateColor(): ResourceColor {
    if (this.battleState === '准备阶段') return '#4CAF50'
    if (this.battleState === '战斗进行中') return '#FF9800'
    if (this.battleState === '战斗结束') return '#2196F3'
    return '#999'
  }
}
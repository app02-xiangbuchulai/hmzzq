// components/ShopPanel.ets
import { ShopHero, Hero, HERO_POOL } from '../model/GameData'

@Component
export struct ShopPanel {
  @State shopHeroes: ShopHero[] = []
  @Prop playerGold: number = 10
  @Prop @Watch('onRoundChange') round: number = 1
  @State playerLevel: number = 1
  @State playerExp: number = 0
  @State maxExp: number = 2
  onBuyHero: (hero: Hero) => void = () => {}
  onRefreshShop: () => void = () => {}

  aboutToAppear(): void {
    this.refreshShop()
  }

  onRoundChange(): void {
    this.refreshShop()
  }

  refreshShop(): void {
    let newShop: ShopHero[] = []
    let pool = [...HERO_POOL]
    for (let i = pool.length - 1; i > 0; i--) {
      let j = Math.floor(Math.random() * (i + 1))
      let temp = pool[i]
      pool[i] = pool[j]
      pool[j] = temp
    }
    for (let i = 0; i < 5 && i < pool.length; i++) {
      let h = pool[i]
      newShop.push({
        heroId: h.id,
        name: h.name,
        cost: h.cost,
        avatar: h.icon,
        isLocked: false
      })
    }
    this.shopHeroes = newShop
  }

  findHeroById(id: string): Hero | undefined {
    for (let i = 0; i < HERO_POOL.length; i++) {
      if (HERO_POOL[i].id === id) {
        return HERO_POOL[i]
      }
    }
    return undefined
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Text('💰')
            .fontSize(24)
          Text(`${this.playerGold}`)
            .fontSize(24)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
            .shadow({ radius: 2, color: '#FFD700' })
        }

        Row({ space: 4 }) {
          Text('等级')
            .fontSize(20)
          Text(`Lv.${this.playerLevel}`)
            .fontSize(20)
            .fontColor('#2196F3')
            .fontWeight(FontWeight.Bold)
          Stack() {
            Row()
              .width(80)
              .height(10)
              .backgroundColor('#EEE')
              .borderRadius(5)
            Row()
              .width(80 * (this.playerExp / this.maxExp))
              .height(10)
              .backgroundColor('#2196F3')
              .borderRadius(5)
          }
          .width(80)
          .height(10)
        }

        Button('🔄 刷新 (2💰)')
          .fontSize(14)
          .height(40)
          .backgroundColor('#FF9800')
          .shadow({ radius: 4, color: '#FF980040' })
          .onClick(() => {
            if (this.playerGold >= 2) {
              this.onRefreshShop()
              this.refreshShop()
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(12)

      if (this.shopHeroes.length === 0) {
        Column({ space: 12 }) {
          Text('🏪 商店已空')
            .fontSize(16)
            .fontColor('#999')
          Button('🆓 免费刷新')
            .fontSize(14)
            .height(40)
            .backgroundColor('#4CAF50')
            .shadow({ radius: 4, color: '#4CAF5040' })
            .onClick(() => this.refreshShop())
        }
        .width('100%')
        .padding(20)
      } else {
        Row({ space: 12 }) {
          ForEach(this.shopHeroes, (shopHero: ShopHero, index: number) => {
            this.ShopCardBuilder(shopHero, index)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(12)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#20000000' })
    .padding(12)
  }

  @Builder
  ShopCardBuilder(shopHero: ShopHero, index: number) {
    Column({ space: 6 }) {
      Text(shopHero.avatar)
        .fontSize(40)
        .width(80)
        .height(80)
        .backgroundColor(this.getHeroColor(shopHero.cost))
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .shadow({ radius: 6, color: this.getHeroColor(shopHero.cost) + '60' })

      Text(shopHero.name)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      Row({ space: 4 }) {
        Text('💰')
          .fontSize(12)
        Text(`${shopHero.cost}`)
          .fontSize(16)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
      }

      Button(this.playerGold >= shopHero.cost ? '🛒 购买' : '❌ 不足')
        .fontSize(13)
        .height(36)
        .width(80)
        .backgroundColor(this.playerGold >= shopHero.cost ? '#4CAF50' : '#9E9E9E')
        .shadow({ radius: 4, color: this.playerGold >= shopHero.cost ? '#4CAF5040' : '#00000000' })
        .enabled(this.playerGold >= shopHero.cost)
        .onClick(() => {
          let hero = this.findHeroById(shopHero.heroId)
          if (hero) {
            this.onBuyHero(hero)
            let newShop: ShopHero[] = []
            for (let i = 0; i < this.shopHeroes.length; i++) {
              if (i !== index) {
                newShop.push(this.shopHeroes[i])
              }
            }
            this.shopHeroes = newShop
          }
        })
    }
    .width(92)
    .padding(10)
    .backgroundColor('#FFF')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#20000000' })
    .opacity(shopHero.isLocked ? 0.5 : 1)
  }

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
}
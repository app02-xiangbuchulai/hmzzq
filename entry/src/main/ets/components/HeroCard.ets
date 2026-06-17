// components/HeroCard.ets
import { Hero } from '../model/GameData'

@Component
export struct HeroCard {
  @Prop hero: Hero
  @Prop isSelected: boolean = false
  @Prop isShop: boolean = false
  cardClick: () => void = () => {}
  cardLongPress: () => void = () => {}

  build() {
    Column({ space: 6 }) {
      Stack() {
        Text(this.hero.icon)
          .fontSize(32)
          .width(64)
          .height(64)
          .backgroundColor(this.hero.color || this.getHeroColor(this.hero.cost))
          .borderRadius(16)
          .textAlign(TextAlign.Center)
          .shadow({ radius: 6, color: (this.hero.color || '#999') + '60' })
          .border({
            width: this.isSelected ? 4 : 0,
            color: '#FFD700'
          })

        if (this.isSelected) {
          Text('✓')
            .fontSize(20)
            .fontColor('#FFD700')
            .position({ x: 40, y: -5 })
            .backgroundColor('#FFF')
            .borderRadius(10)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
        }
      }

      Text(this.hero.name)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      Row({ space: 4 }) {
        Text('💰')
          .fontSize(12)
        Text(`${this.hero.cost}`)
          .fontSize(14)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
      }

      if (!this.isShop) {
        Column({ space: 2 }) {
          Row({ space: 8 }) {
            Text(`❤️ ${this.hero.currentHealth}/${this.hero.maxHealth}`)
              .fontSize(11)
              .fontColor('#F44336')
            Text(`⚔️ ${this.hero.attack}`)
              .fontSize(11)
              .fontColor('#333')
          }
        }
      }

      Row({ space: 4 }) {
        ForEach(this.getTags(), (tag: string) => {
          Text(tag)
            .fontSize(10)
            .fontColor('#FFF')
            .backgroundColor('#666')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        })
      }
    }
    .width(84)
    .padding(10)
    .backgroundColor(this.isSelected ? '#FFF9C4' : '#FFF')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#20000000' })
    .border({
      width: this.isSelected ? 3 : 0,
      color: '#FFD700'
    })
    .onClick(() => this.cardClick())
    .gesture(
      LongPressGesture({ duration: 500 })
        .onAction(() => this.cardLongPress())
    )
  }

  getTags(): string[] {
    return this.hero.origin.concat(this.hero.class)
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
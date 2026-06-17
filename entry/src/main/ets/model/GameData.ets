// model/GameData.ets

export interface Hero {
  id: string
  name: string
  cost: number
  health: number
  maxHealth: number
  attack: number
  defense: number
  magicResist: number
  attackSpeed: number
  attackRange: number
  skillId: string
  origin: string[]
  class: string[]
  currentHealth: number
  currentMana: number
  maxMana: number
  star: number
  position?: Position
  icon: string
  skillIcon: string  // 技能专属图标
  color: string      // 主题色
}

export interface Position {
  row: number
  col: number
}

export interface Skill {
  id: string
  name: string
  damage: number
  damageType: string
  targetType: string
  manaCost: number
  maxMana: number
  effect: string
  skillIcon: string   // 技能释放时的图标
  skillColor: string  // 技能光效颜色
}

export interface BattleHero extends Hero {
  isAlive: boolean
  targetId: string | null
  isAttacking: boolean
  isCasting: boolean
  damageFlash: number
  lastDamage: number
  skillEffect: number  // 技能特效帧计数
}

export interface ShopHero {
  heroId: string
  name: string
  cost: number
  avatar: string
  isLocked: boolean
}

export const BOARD_ROWS = 4
export const BOARD_COLS = 7
export const PLAYER_ROWS = 2
export const INITIAL_GOLD = 10
export const INITIAL_HEALTH = 100
export const SELL_PRICE_RATIO = 0.7

export const CELL_SIZE = 72      // 更大格子
export const AVATAR_SIZE = 40     // 更大头像

export const HERO_POOL: Hero[] = [
  {
    id: 'hero_001', name: '盖伦', cost: 1, icon: '⚔️', skillIcon: '🌀', color: '#4CAF50',
    health: 700, maxHealth: 700, attack: 50,
    defense: 45, magicResist: 35, attackSpeed: 0.55, attackRange: 1,
    skillId: 'skill_001', origin: ['贵族'], class: ['骑士'],
    currentHealth: 700, currentMana: 0, maxMana: 100, star: 1
  },
  {
    id: 'hero_002', name: '薇恩', cost: 1, icon: '🏹', skillIcon: '💘', color: '#9E9E9E',
    health: 500, maxHealth: 500, attack: 65,
    defense: 20, magicResist: 20, attackSpeed: 0.75, attackRange: 3,
    skillId: 'skill_002', origin: ['贵族'], class: ['游侠'],
    currentHealth: 500, currentMana: 0, maxMana: 0, star: 1
  },
  {
    id: 'hero_003', name: '卡萨丁', cost: 2, icon: '🔮', skillIcon: '⚡', color: '#2196F3',
    health: 600, maxHealth: 600, attack: 45,
    defense: 30, magicResist: 40, attackSpeed: 0.65, attackRange: 1,
    skillId: 'skill_003', origin: ['虚空'], class: ['法师'],
    currentHealth: 600, currentMana: 0, maxMana: 80, star: 1
  },
  {
    id: 'hero_004', name: '亚索', cost: 3, icon: '⚡', skillIcon: '🌪️', color: '#FF9800',
    health: 550, maxHealth: 550, attack: 70,
    defense: 25, magicResist: 25, attackSpeed: 0.8, attackRange: 1,
    skillId: 'skill_004', origin: ['浪人'], class: ['剑士'],
    currentHealth: 550, currentMana: 0, maxMana: 100, star: 1
  },
  // ✅ 新增英雄 1：法师 - 安妮
  {
    id: 'hero_005', name: '安妮', cost: 4, icon: '🧸', skillIcon: '🔥', color: '#F44336',
    health: 650, maxHealth: 650, attack: 55,
    defense: 35, magicResist: 50, attackSpeed: 0.6, attackRange: 2,
    skillId: 'skill_005', origin: ['暗影岛'], class: ['法师'],
    currentHealth: 650, currentMana: 0, maxMana: 120, star: 1
  },
  // ✅ 新增英雄 2：刺客 - 劫
  {
    id: 'hero_006', name: '劫', cost: 5, icon: '👤', skillIcon: '💀', color: '#9C27B0',
    health: 480, maxHealth: 480, attack: 85,
    defense: 20, magicResist: 15, attackSpeed: 0.9, attackRange: 1,
    skillId: 'skill_006', origin: ['艾欧尼亚'], class: ['刺客'],
    currentHealth: 480, currentMana: 0, maxMana: 100, star: 1
  }
]

export const SKILL_LIST: Skill[] = [
  {
    id: 'skill_001', name: '审判',
    damage: 150, damageType: 'physical', targetType: 'aoe',
    manaCost: 100, maxMana: 100, effect: '盖伦旋转大剑，对周围敌人造成伤害',
    skillIcon: '🌀', skillColor: '#4CAF50'
  },
  {
    id: 'skill_002', name: '圣银弩箭',
    damage: 80, damageType: 'true', targetType: 'single',
    manaCost: 0, maxMana: 0, effect: '薇恩的攻击附带真实伤害',
    skillIcon: '💘', skillColor: '#9E9E9E'
  },
  {
    id: 'skill_003', name: '虚空之刃',
    damage: 120, damageType: 'magic', targetType: 'single',
    manaCost: 80, maxMana: 80, effect: '卡萨丁发射虚空能量，造成魔法伤害',
    skillIcon: '⚡', skillColor: '#2196F3'
  },
  {
    id: 'skill_004', name: '斩钢闪',
    damage: 60, damageType: 'physical', targetType: 'self',
    manaCost: 100, maxMana: 100, effect: '亚索突进并斩击敌人，获得护盾',
    skillIcon: '🌪️', skillColor: '#FF9800'
  },
  // ✅ 新增技能
  {
    id: 'skill_005', name: '提伯斯之怒',
    damage: 200, damageType: 'magic', targetType: 'aoe',
    manaCost: 120, maxMana: 120, effect: '安妮召唤提伯斯，造成范围火焰伤害',
    skillIcon: '🔥', skillColor: '#F44336'
  },
  {
    id: 'skill_006', name: '禁奥义·瞬狱影杀阵',
    damage: 180, damageType: 'physical', targetType: 'single',
    manaCost: 100, maxMana: 100, effect: '劫化为影子，对目标发动致命一击',
    skillIcon: '💀', skillColor: '#9C27B0'
  }
]

export function getHeroById(id: string): Hero | undefined {
  for (let i = 0; i < HERO_POOL.length; i++) {
    if (HERO_POOL[i].id === id) {
      return HERO_POOL[i]
    }
  }
  return undefined
}

export function getSkillById(id: string): Skill | undefined {
  for (let i = 0; i < SKILL_LIST.length; i++) {
    if (SKILL_LIST[i].id === id) {
      return SKILL_LIST[i]
    }
  }
  return undefined
}

export function createBattleHero(hero: Hero): BattleHero {
  return {
    id: hero.id,
    name: hero.name,
    cost: hero.cost,
    icon: hero.icon,
    skillIcon: hero.skillIcon,
    color: hero.color,
    health: hero.health,
    maxHealth: hero.maxHealth,
    currentHealth: hero.currentHealth,
    attack: hero.attack,
    defense: hero.defense,
    magicResist: hero.magicResist,
    attackSpeed: hero.attackSpeed,
    attackRange: hero.attackRange,
    skillId: hero.skillId,
    origin: hero.origin,
    class: hero.class,
    currentMana: hero.currentMana,
    maxMana: hero.maxMana,
    star: hero.star,
    position: hero.position,
    isAlive: true,
    targetId: null,
    isAttacking: false,
    isCasting: false,
    damageFlash: 0,
    lastDamage: 0,
    skillEffect: 0
  }
}

export function calculateSellPrice(hero: Hero): number {
  return Math.floor(hero.cost * SELL_PRICE_RATIO * hero.star)
}
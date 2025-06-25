export interface Feature {
  icon: React.ComponentType<{ className?: string }>
  title: string
  description: string
  highlight?: boolean
}

export interface Demo {
  id: number
  title: string
  description: string
  image: string
}

export interface Testimonial {
  id: number
  name: string
  role: string
  company: string
  content: string
  rating: number
  avatar: string
}

export interface PricingPlan {
  name: string
  price: string
  period: string
  description: string
  features: string[]
  popular?: boolean
  cta: string
}

export interface FAQ {
  id: number
  question: string
  answer: string
}

export interface Stat {
  number: string
  label: string
  suffix?: string
}

export interface NavItem {
  name: string
  href: string
}
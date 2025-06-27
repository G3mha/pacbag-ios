declare module 'vanilla-tilt' {
  interface VanillaTiltOptions {
    max?: number
    perspective?: number
    scale?: number
    speed?: number
    transition?: boolean
    axis?: 'x' | 'y' | null
    reset?: boolean
    easing?: string
    glare?: boolean
    'max-glare'?: number
    'glare-prerender'?: boolean
    'mouse-event-element'?: string | HTMLElement
    'full-page-listening'?: boolean
    gyroscope?: boolean
    gyroscopeMinAngleX?: number
    gyroscopeMaxAngleX?: number
    gyroscopeMinAngleY?: number
    gyroscopeMaxAngleY?: number
    gyroscopeSamples?: number
  }


  class VanillaTilt {
    static init(elements: HTMLElement | HTMLElement[], options?: VanillaTiltOptions): void
  }

  export = VanillaTilt
}
'use client'

import { useEffect, useRef } from 'react'
import VanillaTilt from 'vanilla-tilt'

interface VanillaTiltElement extends HTMLElement {
  vanillaTilt?: {
    destroy(): void
  }
}

interface TiltOptions {
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


export const useTilt = (options: TiltOptions = {}) => {
  const tiltRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const element = tiltRef.current
    if (!element) return

    const defaultOptions: TiltOptions = {
      max: 15,
      perspective: 1000,
      scale: 1.05,
      speed: 300,
      transition: true,
      axis: null,
      reset: true,
      easing: 'cubic-bezier(.03,.98,.52,.99)',
      glare: true,
      'max-glare': 0.2,
      'glare-prerender': false,
      ...options,
    }

    VanillaTilt.init(element, defaultOptions)

    return () => {
      const tiltElement = element as VanillaTiltElement
      if (tiltElement && tiltElement.vanillaTilt) {
        tiltElement.vanillaTilt.destroy()
      }
    }
  }, [options])

  return tiltRef
}

export default useTilt
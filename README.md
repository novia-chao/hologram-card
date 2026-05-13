# Hologram Card

Small React demo with an interactive hologram card effect.

Live demo: https://joeltankard.github.io/hologram-card/

## Run locally

```sh
npm install
npm run dev
```

## Build

```sh
npm run build
```

## Type check

```sh
npm run typecheck
```

## Notes

Images are passed into `HologramCard` as props:

```tsx
<HologramCard
  images={{ image, depth, shade }}
  aspectRatio={5 / 6}
/>
```

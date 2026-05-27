<img src="https://raw.githubusercontent.com/Krutikgohel/explode/main/assets/icon/explode_icon.png" alt="explode logo"/>

[![Pub Version](https://img.shields.io/pub/v/explode?style=flat-square&color=blue)](https://pub.dev/packages/explode)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Pub Points](https://img.shields.io/pub/points/explode?style=flat-square&color=green)](https://pub.dev/packages/explode)
![Dart](https://img.shields.io/badge/Dart-%3E%3D2.17-blue?style=flat-square&logo=dart)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0-blue?style=flat-square&logo=flutter)

## Description

A lightweight Flutter package that turns any widget into a satisfying particle explosion. Wrap your UI, trigger the blast with an `ExplodeController`, and watch the child shatter into colorful particles with physics-based motion.

## Features

- Pixel-perfect explosion by sampling the child widget into particles
- Programmatic control via `ExplodeController` (`explode()` and `reset()`)
- Customizable particle shapes: circle, rectangle, and triangle
- Adjustable animation duration for fast, normal, or slow effects
- Control particle density with `particleSize` or `particleCount`
- Constrain spread with `explodeArea` for tight or wide blasts
- Works with simple widgets and complex UI layouts

## Explode Types

### Default effect

Out-of-the-box explosion with circle particles and standard duration.

<p align="center">
  <img src="assets/default.gif" width="320" alt="Default explode effect"/>
</p>

### Particle shapes

Choose circle, rectangle, or triangle particles for a different visual style.

<table border="0" cellspacing="0" cellpadding="8" rules="none" frame="void">
<tr>
<td align="center" width="33%" style="border: none;"><img src="assets/circle_particles.gif" width="100%" alt="Circle particles"/><br/><sub>Circle</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/rectengle_particles.gif" width="100%" alt="Rectangle particles"/><br/><sub>Rectangle</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/triangle_particles.gif" width="100%" alt="Triangle particles"/><br/><sub>Triangle</sub></td>
</tr>
</table>

### Effect speed

Tune `duration` to make particles burst quickly or drift slowly.

<table border="0" cellspacing="0" cellpadding="8" rules="none" frame="void">
<tr>
<td align="center" width="33%" style="border: none;"><img src="assets/fast_speed.gif" width="100%" alt="Fast speed"/><br/><sub>Fast</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/normal_speed.gif" width="100%" alt="Normal speed"/><br/><sub>Normal</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/slow_speed.gif" width="100%" alt="Slow speed"/><br/><sub>Slow</sub></td>
</tr>
</table>

### Particle size & count

Use `particleSize` or `particleCount` to control how fine or dense the blast looks.

<table border="0" cellspacing="0" cellpadding="8" rules="none" frame="void">
<tr>
<td align="center" width="33%" style="border: none;"><img src="assets/small_particles.gif" width="100%" alt="Small particles"/><br/><sub>Small</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/large_particles.gif" width="100%" alt="Large particles"/><br/><sub>Large</sub></td>
<td align="center" width="33%" style="border: none;"><img src="assets/particles_count.gif" width="100%" alt="Particle count"/><br/><sub>Count</sub></td>
</tr>
</table>

### Complex UI

Explode rich layouts such as profile cards and buttons without extra setup.

<table border="0" cellspacing="0" cellpadding="8" rules="none" frame="void">
<tr>
<td align="center" width="50%" style="border: none;"><img src="assets/profile_card.gif" width="100%" alt="Profile card explode"/><br/><sub>Profile card</sub></td>
<td align="center" width="50%" style="border: none;"><img src="assets/button_view.gif" width="100%" alt="Button explode"/><br/><sub>Button</sub></td>
</tr>
</table>

### Explode area

Set `explodeArea` to limit how far particles travel from the widget.

<table border="0" cellspacing="0" cellpadding="8" rules="none" frame="void">
<tr>
<td align="center" width="50%" style="border: none;"><img src="assets/small_area.gif" width="100%" alt="Small explode area"/><br/><sub>Small area</sub></td>
<td align="center" width="50%" style="border: none;"><img src="assets/large_area.gif" width="100%" alt="Large explode area"/><br/><sub>Large area</sub></td>
</tr>
</table>

## Examples

### Simple Example

```dart
Explode(
  controller: controller,
  child: GestureDetector(
    onTap: controller.explode,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
      child: const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
    ),
  ),
)
```

### Advanced Example

```dart
Explode(
  controller: controller,
  duration: const Duration(milliseconds: 750),
  shape: ExplodeParticleShape.triangle,
  particleCount: 400,
  explodeArea: const Size(180, 180),
  child: GestureDetector(
    onTap: controller.explode,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('🎁  Open Gift', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
    ),
  ),
)
```

See the [`example`](example/) app for a full interactive demo covering all explode types.

## Installation

Add `explode` to your `pubspec.yaml`:

```yaml
dependencies:
  explode: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

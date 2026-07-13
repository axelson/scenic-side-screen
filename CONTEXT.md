# Context

## Glossary

- **Dashboard**: The overall system — a dedicated Raspberry Pi touchscreen device that aggregates control surfaces for a desk/home-office setup. Hosts multiple Apps and provides a Launcher to switch between them.
- **Launcher**: The mechanism that switches between Apps on the Dashboard. The user can navigate to any App from any other App.
- **App**: A self-contained screen on the Dashboard that the user can switch to via the Launcher. Examples: Piano, Pomodoro, Asteroids, Govee, Keylight.
- **Home App (Piano)**: The default App that appears first on the Dashboard. Originally a control interface for pianobar (a CLI Pandora music player), it has evolved into a general-purpose dashboard that surfaces controls from other Apps. Named "Piano" for historical reasons.
- **Meeting**: A manually-triggered state (activated via keyboard shortcut) indicating the user is in a video call. Triggers coordinated device changes: keylight activates, audio routing adjusts, and light-based indicators signal availability.
- **Govee Lights**: Bluetooth LE smart bulbs controlled from the Dashboard for general lighting (color, brightness). Historically also served as meeting status indicators (semaphore) but that role has diminished.
- **Keylight**: The video/desk light used primarily during Meetings. Distinct from Govee Lights which are ambient room lighting. Named after the Elgato Key Light hardware.
- **Pomodoro**: A work timer App following the Pomodoro Technique. Completed sessions are logged to an Obsidian vault for personal productivity tracking.

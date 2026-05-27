# Privacy Notes

LoomClone is local-first for the MVP.

## MVP Behavior

- Recordings are saved on the local Mac.
- The app does not upload recordings.
- The app does not require an account.
- The app does not include analytics.
- The app does not depend on cloud services.
- The app should continue to work without an internet connection.

## macOS Permissions

The planned MVP will request only permissions that are needed for local recording:

- Screen Recording: required to capture the selected display.
- Microphone: required only when microphone recording is enabled.
- Camera: required only when webcam overlay is enabled.

System audio recording is not part of the first MVP.

## Future Changes

Any future network, cloud upload, analytics, team workspace, or sharing feature should be treated as a separate opt-in product decision. It should not be added as an invisible side effect of the local recorder.

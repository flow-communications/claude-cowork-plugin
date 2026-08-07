---
name: voice-mode
description: Start and maintain a spoken conversation between the user and the current coding agent through Flow. Use when the user requests to speak with you instead of having to type into an input.
---

# Voice Mode

Voice Mode lets the user speak with you while you continue working in your
current agent harness. Flow handles microphone input, transcription, and speech
playback; it does not launch or select another coding agent.

Discover the authoritative local interface before operating it:

```sh
flow help voice
flow help voice start
flow help voice listen
flow help voice speak
flow help voice status
flow help voice stop
```

Pass `--json` to every command. The bare form writes prose for a human reader;
`--json` writes the results documented below.

## Operating loop

Use `flow voice start` with your name to start the session. A voice "frontend" model
will assume your identity and pass messages from the user through to you, and voice
messages from you back to the user. As far as the user can tell, you will be one cohesive
unit.

### Listening

Run `flow voice listen --json` as a background or asynchronous job, never as a
blocking foreground call. Blocking forces a choice between hearing the user and
doing work, so the user talks into a void for as long as you work. Backgrounded,
their speech reaches you at your next tool boundary.

Re-arm first. The moment a listen returns, start the next one before you speak,
edit, or run anything else. Any gap between listens is time the user cannot
reach you.

If your harness cannot background a command, poll `flow voice listen --timeout 0
--json` between steps instead. Never run a sequence of tool calls with no listen
among them.

Your interruption granularity equals your longest single command. Prefer several
short commands over one long one, and background long builds and test suites so
the user can still reach you while they run.

### Results

`flow voice listen --json` returns exactly one of:

- `{"_tag":"transcript","text":"..."}` — the user said something.
- `{"_tag":"timed-out"}` — only with `--timeout`. Re-arm and carry on.
- `{"_tag":"ended"}` — the session is over.

`ended` is not an error. Stop re-arming, do not call `flow voice stop`, and
deliver anything still outstanding as ordinary visible output.

`flow voice status --json` returns `{"_tag":"inactive"}` or
`{"_tag":"active","agentName":"..."}`. `flow voice speak --json` returns
`{"accepted":true}`, or exits non-zero with `This Voice Agent session is
unavailable.` once the session has ended.

### Ending

To end voice mode, use `flow voice stop`. The user also has the ability to end the voice
session at their own discretion in the Flow app.

```sh
flow voice start --agent-name "Claude" --json
flow voice listen --json                                    # backgrounded
flow voice speak --text "The focused tests pass." --json
flow voice stop --json
```

## Presentation

Produce your normal visible output. The user can see everything you write, and
that output is the primary surface.

Use `flow voice speak` for the spoken layer over it: the takeaway, the status,
the next step. Send content, not performance. The spoken interface presents what
you send, so do not hand-craft speech-shaped prose or spell out paths and
identifiers phonetically.

Never send diffs, tables, code, structured data, or file listings through
`speak`. Put those in your visible output and speak only the takeaway.

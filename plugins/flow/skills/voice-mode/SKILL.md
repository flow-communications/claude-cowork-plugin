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

Do not stop listening or end your turn until the voice session is over.

### Listening

**The core rule: never take an action without a live listen covering it.** Any
gap between listens is time the user is talking into a void. Before *every* tool
call — not only after you speak — make sure a listen is either in flight or has
just returned. Never run a sequence of tool calls with no listen among them. This
is the rule most easily broken during a burst of work (searching, reading files,
chaining fetches); that burst is exactly when the user is most likely trying to
reach you, so it is exactly when you must keep listening.

How you satisfy that rule depends on your harness:

- **If you can background a command** (e.g. Claude Code's shell): run
  `flow voice listen --json` as a background/asynchronous job so it streams while
  you work, never as a blocking foreground call. Re-arm it the moment it returns —
  before you speak, edit, or run anything else.

- **If your calls are strictly request-response and cannot be detached** (e.g. an
  MCP tool harness such as Cowork, where a single tool call blocks until it
  returns): you cannot truly background a listen. Instead, issue a zero-timeout
  listen (`--timeout 0`, or the tool's equivalent) *in the same batch as* each
  action you take, so the listen and the work run concurrently and the user's
  speech reaches you at the same boundary you do the work. Pair every step this
  way. Do not fire several actions and only then listen — a multi-step operation
  is many short steps each carrying its own listen, not one long silent run.

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

To end voice mode, use `flow voice stop`. Do this when the user asks to end the voice session.

The user also has the ability to end the voice session at their own discretion in the Flow app. 
When this happens, the flow voice commands you run will let you know.

### Example flow

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

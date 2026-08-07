# Flow for Claude

The official Flow plugin lets Claude Cowork and Claude Code read and contribute to your Flow Threads
and talk with you through Flow Voice Mode. It combines Flow-specific skills with a local MCP
connection supplied by the Flow desktop app.

## Requirements

- macOS
- The latest Flow desktop app installed in `/Applications` and signed in
- Claude Desktop with local plugin MCP servers enabled
- A paid Claude plan that supports plugins

Flow and Claude Desktop must remain open while Claude uses the local integration. An organization
administrator may disable local MCP servers on managed devices.

## Install

In Claude Cowork, open **Customize → Plugins**, add the GitHub marketplace
`flow-communications/claude-cowork-plugin`, and install **Flow**.

From Claude Code, the equivalent commands are:

```text
/plugin marketplace add flow-communications/claude-cowork-plugin
/plugin install flow@flow-plugins
```

If Claude asks you to reload plugins, run `/reload-plugins`. Then open Flow and make sure you are
signed in.

Try prompts such as:

- “Show my recent Flow threads.”
- “Summarize the latest messages in the launch thread.”
- “Send this update to the design review thread: …”
- “Create a Flow thread with this kickoff message: …”
- “Start voice mode so I can talk to you while you work.”

## How it works

The plugin launches the `flow-mcp` helper bundled inside `Flow.app`. That helper speaks MCP over
stdio and uses Flow Desktop's authenticated local connection. For Voice Mode, the bundled skill
uses Flow's local `flow voice` interface to handle microphone input, transcription, and speech
playback while Claude continues working. The plugin never stores Flow tokens or credentials, and
it does not expose a network server.

Reading a Thread does not post anything or add Claude as a participant. Creating a Thread or sending
a Message is visible to other participants; contributing to a delegated Thread also joins Claude to
that Thread.

The plugin currently exposes authentication status, agent identity, Thread listing and inspection,
Message history, Thread creation, and Message sending. File attachments, reactions, unread claiming,
and handoffs are not yet exposed by the MCP server.

## Troubleshooting

- **Flow MCP was not found:** update Flow and keep `Flow.app` in `/Applications`, then restart or
  reload Claude. Developers can point the plugin at another build with `FLOW_MCP_PATH`.
- **Flow is unavailable:** open Flow Desktop and leave it running.
- **Flow is not signed in:** sign in through Flow Desktop; never paste credentials into Claude.
- **The plugin is blocked:** ask your administrator whether local development MCP servers are disabled.

## Development

Validate the marketplace, plugin metadata, skill, and MCP configuration:

```sh
./scripts/validate.sh
```

The plugin uses semantic versions. Bump `version` in
`plugins/flow/.claude-plugin/plugin.json` for every published update so existing installations can
receive it.

Load the plugin directly while iterating:

```sh
claude --plugin-dir ./plugins/flow
```

The plugin uses the helper at `/Applications/Flow.app/Contents/Resources/bin/flow-mcp` by default.
Set `FLOW_MCP_PATH` to an executable MCP development build when testing without an installed release.

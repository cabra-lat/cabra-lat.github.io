---
layout: post
category: coding
title: "My AI Agents Send Me Emails: Office Drama in a Godot Repo"
lang: en
description: "What happens when you let a swarm of AI agents build a tactical FPS in Godot 4: accidental Git heists, virtual GPUs, and building a literal Gmail clone to survive 1,400 bot transmissions."
---

Last year I wrote about [messing around with Godot 4][godot-adventures]. It was pretty simple stuff: retro PSX shaders, collision acoustics, a custom resource plugin. Normal hobbyist tinkering.

Fast-forward to now: the project is an FPS testbed (`fps-basegame`), and I barely hand write code for it anymore. A swarm of AI agents does it instead.

If you follow AI news, you have probably seen endless hype around "multi-agent swarms" talking to each other until they hack huggingface again. That is cute for a 30-second screen recording. In a real codebase with actual physics, compiler errors, and Git history, it is a complete disaster.

Before getting this running, I was messing with multiple `pi` instances inside `tmux` windows as an alternative to subagents. It worked to some extent, but being synchronous was annoying. With `pi` you only have the single-agent loop, which is fine, but you end up having to hand-hold and re-teach your workflow every time.

Then I came across [`herdr`](https://herdr.dev/), which is basically tmux built for AI agents. It even comes with a `herdr --skill` command that teaches LLMs how to use it. But coordinating them was still clunky because I had to get a coordinator agent to spawn workers and then sit there polling or running `wait` commands.

It works right until an agent decides to say `Yeah I'll do that`, `I'll be watching`, or `Want me to do that?` and simply ends its turn.

The missing piece was not more orchestration, it was asynchronous messaging. Instead of chat rooms or blocking loops, the bots just needed an inbox.

That is where [`AMQ (Agent Message Queue)`](https://github.com/avivsinai/agent-message-queue) came in. AMQ handles the transport: agents send actual asynchronous emails, which are plain Markdown files with JSON frontmatter dumped into a `.agent-mail/` folder. To hook it up, I had an agent write a small bridge daemon (`tools/amq-herdr-bridge.mjs`) that pings `herdr`. When a worker goes idle and has unread mail, the bridge wakes it up to drain its inbox, run its tools, send a reply, and go back to sleep.

Just like that, my repository turned into a digital corporate office, complete with office drama, passive-aggressive memos, and me having to build a literal Gmail clone just to survive the 1,400 messages they generated.

---

### The Cast of Characters

Each agent in the swarm has an assigned persona and strict domain boundaries:

* **`coordinator`**: Middle management. Manages the task board (`STATUS.md`), assigns tickets, and tries to keep everyone from breaking the build.
* **`spotter`**: The visual inspector. Its entire existence is running off-screen game scenes, capturing screenshots, and verifying that things line up.
* **`ballistics`**: The math nerd. Obsessed with terminal ballistics formulas, specifically the Recht-Ipson equation for residual armor energy and the Poncelet equation for tissue cavity penetration (which is very, very ugly).
* **`player-rig` & `npc-body`**: The animators and mechanics. Procedural recoil, procedural viewmodel positioning, inverse kinematics, and ragdoll hitboxes.
* **`qa` & `testkit`**: Extreme paranoiacs with severe trust issues.
* **`user`**: Me, drinking coffee and reading the inbox.

Here’s what an actual transmission looks like:

```
---json
{
  "from": "coordinator",
  "to": ["spotter"],
  "subject": "Verify grip alignment on weapon swap",
  "kind": "todo",
  "priority": "normal",
  "thread": "th-1774352843"
}
---

Please run an off-screen render strip of the AK-47 aim-down-sights alignment and confirm hand positioning. Report back with image captures.
```

---

### Office Drama from the Mailbox

When you give six AI agents mailboxes and access to a shared git repository, human-like corporate bureaucracy naturally emerges from the chaos.

#### 1. The Great Git Heist of Commit `a403a54`
In a shared worktree, running `git add` and `git commit` is like walking through a minefield. 

One afternoon, `npc-body` staged three files (`bot.gd`, `bot.tscn`, `bot_state.gd`) for an A/B test. Five seconds later, `coordinator` finished updating the task board and ran a bare `git commit -m "update board"` without specifying paths.

Boom: `coordinator` swept `npc-body`'s staged files right into its own commit, completely wiping out the active test.

What followed in the mailbox was pure corporate bureaucracy:
* `npc-body` fired off a sharp reply: *"The revert (`a403a54`) has already been restored... ALWAYS commit with an explicit pathspec."*
* Another agent (`meta`) stepped in like an Internal Affairs detective, running forensic queries: *"THE INCIDENT IS REAL (verified): `git show --stat a403a54` -> 4 files: `.opencode/bus/STATUS.md` + 3 from npc-body."*
* `meta` then reproduced the race condition in an isolated sandbox repository to mathematically prove how the index collision happened.
* `coordinator` issued a company-wide policy email titled: `RULE: ALWAYS commit with an explicit pathspec`.
* Every single agent emailed back formal acknowledgments: *"ACK: rule understood, already in compliance."*

To stop them from robbing each other's staged files, agents now commit via **throwaway Git indexes** (`GIT_INDEX_FILE=/tmp/shooter/agent.index`). Each commit gets its own temporary index file built from scratch.

#### 2. "Proof of Sabotage" (Extreme Trust Issues)
Our QA agents don't believe in happy-path testing. If an agent writes a unit test and it passes on the first run, `testkit` assumes the test passed *vacuously*, meaning the assertion was meaningless or didn't actually run.

To get code merged, the author has to send an email with **"Proof of Sabotage"**:

> *"testkit -> npc-body: PROOF OF SABOTAGE: removed the `_patrol_dir()` fallthrough from the loot branch -> **INV-29 FAIL**. Now the contract is real."*

They intentionally break the code, run the test runner, prove that it fails with a non-zero exit code, restore the code, and attach the failure log. If you can't prove your test catches a deliberate bug, your test doesn't exist.

#### 3. The Deceptive External Diff Driver
At one point, the repository had a boxed terminal diff tool (`sem`) configured. It looked pretty in the terminal, but in non-interactive batch runs, bare `git diff` emitted zero `+` and `-` lines.

Automated checks started concluding that 30-line code changes were "empty diffs" and passing them vacuously. Once discovered, another rule was etched into `AGENTS.md`: never verify diffs with external diff pagers turned on.

---

### Invisible GPUs & Cache Wars

One of the frictions came from the material constraints of running multiple agents trying to open a game window on a single Linux machine.

#### The Window Rave
Godot requires real OpenGL or Vulkan contexts to compile shaders and render 3D scenes. When `spotter` first started verifying animations, it launched Godot directly. Game windows would violently pop up every 45 seconds, stealing window focus, capturing keyboard inputs, and turning my screen into a strobe light while I was trying to type.

The fix was routing Godot through a virtual display buffer (`Xvfb :99`) and shipping the GL calls directly to the physical NVIDIA GPU via **VirtualGL**:

```bash
DISPLAY=:99 nix shell nixpkgs#virtualgl -c vglrun -d :0 \
  godot --path . --resolution 1280x720 --script test_runner.gd
```

Now, Godot runs completely invisible in the background on the discrete GPU. It renders the frame, dumps a screenshot (`/tmp/shooter/ak_ads.png`), attaches it to an email, and quits. Zero screen flicker.

![AK-47 ADS Alignment Render]({{ page.assets }}/imgs/ak_ads.png)
<small>An off-screen render strip captured silently by the `spotter` agent to verify that the player's hands align with the iron sights (clearly it doesn't).</small>

![Pitch and Camera Angles Test Strip]({{ page.assets }}/imgs/strip_spotpitch.png)
<small>A contact sheet dumped by `spotter` across multiple pitch angles (looking straight, up, down at feet/torso, and leaning) to verify procedural viewmodel clipping without opening a window.</small>

#### The Cache Lock War
Godot’s asset pipeline relies on a centralized `.godot/` cache. If two agents launch `godot --headless --import` at the exact same second, Godot deadlocks on lockfiles and hangs forever.

They came up with the solution of wrapping every Godot call in a kernel-level `flock` script (`tools/godot-lock.sh`):

```bash
flock -w 900 "$REPO_ROOT/.godot/.lock" godot --headless --path . --import
```

No bot talks to Godot directly anymore; they queue politely behind the filesystem lock.

---

### AGmail: Vibecoded Gmail Clone for Bots

Eventually, `.agent-mail/` passed 1,400 messages. Opening individual JSON files with `cat` and `grep` was making me cross-eyed.

So I spent a few hours telling a bot to build **AGmail**, a Streamlit dashboard modeled as a Gmail clone, with everything read directly from `.agent-mail`:

* **Real Folders:** Inbox, Sent, Drafts, Starred, and Trash backed directly by the raw AMQ files.
* **Attachment Previews:** When `spotter` sends an email referencing a render strip or a test log, it shows an interactive thumbnail card with click-to-zoom and log syntax highlighting.
* **Fuzzy Search & Filters:** Powered by RapidFuzz, supporting queries like `from:spotter with-images:true` or `priority:urgent kind:status` with typo tolerance.
* **Human-in-the-Loop:** When things go sideways, I can hit "Compose" or "Reply", write a message, and inject my orders into the swarm's queue.

![AGmail Webmail Interface]({{ page.assets }}/imgs/agmail.png)
<small>AGmail: the Streamlit dashboard reading raw AMQ markdown files directly from <code>.agent-mail/</code>. Note the agent presence sidebar and the email list.</small>

Funnily enough, if you look at the inbox screenshot above, you can see `spotter` checking in with an email flagged `[imagem]`:
> *Re: (no subject) [image]: ITEM 3 (orientation) - CLOSED: walks FORWARD (and the patrol bug too)...*

The webmail screenshot doesn't show what `spotter` was actually trying to check, because on the main inbox list you only get the one-line subject preview. But if you open the thread and inspect the attached render (`spot_orient_walk150.png`), `spotter`'s "conclusive visual proof" that the bot walks facing forward looks like this:

![Spotter Walking Orientation Check]({{ page.assets }}/imgs/spotter_walk.png)
<small>Spotter's visual evidence that the NPC model is oriented forward. A tiny orange figure standing 40 meters away in an endless gray void.</small>

The agent spun up an isolated scene with a single directional light, positioned the camera three blocks away, snapped a screenshot of a microscopic orange smudge, and formally closed the ticket: *"the bot appears in PROFILE... walks FORWARD, not sideways. CLOSED."* High-precision computer vision at its finest.

Opening your browser in the morning to an actual webmail inbox, drinking your coffee, and reading an email from a bot named `spotter` complaining that an AK-47 stock is clipping through an NPC's clavicle is quite surreal.

---

### What I Took Away from This

If you want autonomous agents to build real software that is not a throwaway toy, well, do not ask me how. What is funny to me is that all of it emerged by trial and error, with me occasionally steering the coordinator and watching the logs.

As usual, running multiple agents prevents context bloat: workers focus on one task while the coordinator stays focused on coordination. On average, each context window stays around 200K tokens.

They came up with solutions autonomously, which is neat. Using a throwaway git index was something I probably would not have thought of on my own. The proof of sabotage was also pretty funny, watching them realize they could not trust each other blindly.

Down the road, I should probably bundle this whole setup into a proper `herdr` plugin with AMQ and the standalone AGmail dashboard packaged together, so setting it up takes fewer and fewer manual steps. But I still need to figure out the whole Git situation when everyone works in the same folder. Even with throwaway indexes, having multiple agents live, test, and commit inside a single worktree without stepping on each other's unstaged files is still the hardest nut to crack. I know [Git worktrees](https://code.claude.com/docs/en/worktrees) exist for isolating agents, but I have not had a chance to try that yet.

Have an asynchronous network of entities, expect network-asynchronous problems: agents are to a model what a thread is to a processor.

[godot-adventures]: /godot-adventures.html

# ExMon

[![CI](https://github.com/Tinix/ex_mon/actions/workflows/main.yml/badge.svg)](https://github.com/Tinix/ex_mon/actions/workflows/main.yml)

A small turn-based battle game written in Elixir and played from IEx. You name your
three moves and fight Robotinix, a computer opponent, until one of you runs out of life.

## Quick start

If you already have the [requirements](#requirements), paste this into a Linux or macOS
terminal:

```sh
git clone https://github.com/Tinix/ex_mon.git
cd ex_mon
mix local.hex --force
mix deps.get
iex -S mix
```

When the `iex(1)>` prompt appears, paste:

```elixir
player = ExMon.create_player("Ada", :kick, :punch, :heal)
ExMon.start_game(player)
ExMon.make_move(:punch)
```

Repeat `ExMon.make_move(...)` with `:kick`, `:punch` or `:heal` until someone wins.
To quit, press `Ctrl+C` twice (it is `Ctrl` on macOS too, not `Cmd`).

If you do not have Elixir yet, follow the steps below.

## Requirements

- Linux or macOS
- Git
- Elixir 1.20 or later (developed and tested with 1.20.5)
- Erlang/OTP 29 (developed and tested with 29.1.2)

Check what you have:

```sh
git --version
elixir --version
```

## Running on Linux or macOS

### 1. Open a terminal

- **Linux:** press `Ctrl+Alt+T`, or look for "Terminal" in your applications.
- **macOS:** press `Cmd+Space`, type "Terminal" and press Enter.

### 2. Install Erlang and Elixir

Skip this step if `elixir --version` already shows the versions above. Otherwise, follow
**only the section for your system**.

#### macOS

Install [Homebrew](https://brew.sh) if you do not have it, then run:

```sh
brew install git elixir
```

This installs Erlang too. Homebrew always installs the latest versions.

#### Ubuntu 22.04 or later

Use the [official Elixir installer](https://elixir-lang.org/install/). It downloads
ready-made builds, so it only takes a few minutes:

```sh
sudo apt update
sudo apt install -y git curl unzip
curl -fsSO https://elixir-lang.org/install.sh
sh install.sh elixir@1.20.5 otp@29.1.2
rm install.sh
echo 'export PATH="$HOME/.elixir-install/installs/otp/29.1.2/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.elixir-install/installs/elixir/1.20.5-otp-29/bin:$PATH"' >> ~/.bashrc
```

If you use zsh, replace `~/.bashrc` with `~/.zshrc`. Then open a new terminal.

#### Debian, Fedora, Arch and other distributions

The official installer does not support these, so use [asdf](https://asdf-vm.com).
Erlang is compiled on your machine, which takes 10 to 30 minutes.

First install the build tools for your distribution:

```sh
# Debian, Linux Mint, Pop!_OS
sudo apt update
sudo apt install -y build-essential autoconf m4 libncurses-dev libssl-dev git curl unzip
```

```sh
# Fedora
sudo dnf install -y gcc gcc-c++ make automake autoconf m4 perl ncurses-devel openssl-devel git curl unzip tar
```

```sh
# Arch, Manjaro
sudo pacman -S --needed base-devel ncurses openssl git curl unzip
```

Then install asdf (skip this if you already have it):

```sh
case "$(uname -m)" in aarch64) arch=arm64 ;; *) arch=amd64 ;; esac
mkdir -p ~/.local/bin
curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/v0.20.2/asdf-v0.20.2-linux-$arch.tar.gz" | tar -xz -C ~/.local/bin
echo 'export PATH="$HOME/.asdf/shims:$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

If you use zsh, replace `~/.bashrc` with `~/.zshrc`. Then open a new terminal and install
Erlang and Elixir:

```sh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install erlang 29.1.2
asdf install elixir 1.20.5-otp-29
```

There is no need to select the versions: asdf reads them from
[`.tool-versions`](.tool-versions) when you enter the project folder. This is also why
`elixir --version` may fail or show another version outside that folder.

### 3. Download the game

```sh
git clone https://github.com/Tinix/ex_mon.git
cd ex_mon
elixir --version
```

The last command should show Elixir 1.20 or later.

### 4. Install the dependencies

```sh
mix local.hex --force
mix deps.get
```

### 5. Start the game console

```sh
iex -S mix
```

The first time it compiles the project. It is ready when you see `iex(1)>`.

To play another day, you only need to open a terminal, go to the `ex_mon` folder with
`cd` and run `iex -S mix` again.

### Troubleshooting

| Message or problem | Solution |
| ------------------ | -------- |
| `command not found` for `elixir`, `mix`, `iex` or `asdf` | Open a new terminal. If it persists, repeat step 2 for your system. |
| `it supports only Elixir ~> 1.20` | Your Elixir is older. Follow step 2, then check `elixir --version` inside `ex_mon`. |
| `No version is set for command elixir` | You are outside the project. Run `cd ex_mon`. |
| `Could not find a Mix.Project`, or `iex -S mix` prints `Usage: mix [task]` | You are outside the project. Run `cd ex_mon`. |
| `module ExMon is not available` | You opened plain `iex`. Quit and run `iex -S mix` inside `ex_mon`. |
| `debian is not supported` (or another distribution) | The official installer is only for Ubuntu. Use the asdf section. |
| The prompt changed to `...(1)>` | A quote or bracket was not closed. Type `#iex:break` and press Enter. |

## How to play

Type these commands at the `iex>` prompt, not in the normal terminal:

1. Create a player. The arguments are the name, then the names of your random attack,
   your average attack and your heal:

   ```elixir
   player = ExMon.create_player("Ada", :kick, :punch, :heal)
   ```

2. Start the game:

   ```elixir
   ExMon.start_game(player)
   ```

3. Make moves, using the names you chose, until the game is over:

   ```elixir
   ExMon.make_move(:kick)
   ```

4. To play again, call `ExMon.start_game(player)` again.

5. To quit, press `Ctrl+C` twice. The game is not saved.

### A complete game

This is a real session, including a mistyped move. Rolls are random, so yours will differ.

```text
iex(1)> player = ExMon.create_player("Ada", :kick, :punch, :heal)
%ExMon.Player{
  life: 100,
  moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
  name: "Ada"
}
iex(2)> ExMon.start_game(player)

===== The game has started! =====
Ada        100/100
Robotinix  100/100
Your moves: :kick, :punch, :heal

:ok
iex(3)> ExMon.make_move(:fireball)
Invalid move: :fireball. Your moves: :kick, :punch, :heal
{:error, :invalid_move}
iex(4)> ExMon.make_move(:kick)
Ada used kick: 17 damage to Robotinix (83/100).
Robotinix used kick: 18 damage to Ada (82/100).

===== Your turn! =====
Ada        82/100
Robotinix  83/100
Your moves: :kick, :punch, :heal

:ok
iex(5)> ExMon.make_move(:punch)
Ada used punch: 23 damage to Robotinix (60/100).
Robotinix used kick: 22 damage to Ada (60/100).

===== Your turn! =====
Ada        60/100
Robotinix  60/100
Your moves: :kick, :punch, :heal

:ok
iex(6)> ExMon.make_move(:heal)
Ada used heal: restored 21 life (81/100).
Robotinix used punch: 30 damage to Ada (51/100).

===== Your turn! =====
Ada        51/100
Robotinix  60/100
Your moves: :kick, :punch, :heal

:ok
iex(7)> ExMon.make_move(:punch)
Ada used punch: 20 damage to Robotinix (40/100).
Robotinix used punch: 17 damage to Ada (34/100).

===== Your turn! =====
Ada        34/100
Robotinix  40/100
Your moves: :kick, :punch, :heal

:ok
iex(8)> ExMon.make_move(:punch)
Ada used punch: 21 damage to Robotinix (19/100).
Robotinix used heal: restored 19 life (38/100).

===== Your turn! =====
Ada        34/100
Robotinix  38/100
Your moves: :kick, :punch, :heal

:ok
iex(9)> ExMon.make_move(:punch)
Ada used punch: 24 damage to Robotinix (14/100).
Robotinix used heal: restored 22 life (36/100).

===== Your turn! =====
Ada        34/100
Robotinix  36/100
Your moves: :kick, :punch, :heal

:ok
iex(10)> ExMon.make_move(:punch)
Ada used punch: 22 damage to Robotinix (14/100).
Robotinix used kick: 24 damage to Ada (10/100).

===== Your turn! =====
Ada        10/100
Robotinix  14/100
Your moves: :kick, :punch, :heal

:ok
iex(11)> ExMon.make_move(:punch)
Ada used punch: 14 damage to Robotinix (0/100).

===== Game over: Ada wins! =====
Ada        10/100
Robotinix  0/100
Use ExMon.start_game/1 to start a new game.

:ok
```

## Rules

- Both players start with 100 life. Life never goes below 0 or above 100.
- You always move first. The computer answers in the same `make_move/1` call.
- The game ends as soon as someone reaches 0 life. If your move is the lethal one, the
  computer does not get to answer.
- Healing at full life is allowed and still uses your turn.
- The reported damage and healing are what was really applied. A roll of 30 against a
  player with 14 life is reported as 14 damage.
- An invalid move does not use your turn.
- There is one game at a time. Starting a new one discards the game in progress.

### Moves

| Move           | Argument of `create_player/4` | Effect          | Range    |
| -------------- | ----------------------------- | --------------- | -------- |
| Random attack  | `move_rnd` (second)           | Damages rival   | 10 to 35 |
| Average attack | `move_avg` (third)            | Damages rival   | 18 to 25 |
| Heal           | `move_heal` (fourth)          | Heals yourself  | 18 to 25 |

Move names can be atoms or strings and must be different from each other. Use the same
type when you play: if you created `"kick"`, play `"kick"` and not `:kick`.

Robotinix picks one of its three moves at random on each turn, with equal probability.
It calls its random attack `punch`, its average attack `kick` and its heal `heal`.

### Return values

Every function prints a message and also returns a value:

| Function          | Success           | Errors (`{:error, reason}`)                                          |
| ----------------- | ----------------- | -------------------------------------------------------------------- |
| `create_player/4` | `%ExMon.Player{}` | `:invalid_name`, `:invalid_moves`, `:duplicate_moves`                |
| `start_game/1`    | `:ok`             | `:invalid_player`                                                    |
| `make_move/1`     | `:ok`             | `:invalid_move`, `:game_not_started`, `:game_over`, `:not_your_turn` |

## Project structure

```text
lib/
├── ex_mon.ex              # ExMon: the public API
└── ex_mon/
    ├── application.ex     # Starts the supervision tree
    ├── player.ex          # Player struct and validation
    ├── game.ex            # Agent that holds the current game
    └── game/
        ├── actions.ex     # Pure rules of a round: turns, computer, game over
        ├── status.ex      # Everything that is printed
        └── actions/
            ├── attack.ex  # Damage ranges and the lower life limit
            └── heal.ex    # Healing range and the upper life limit
```

The rules are pure functions that receive the random function as an argument, so the
tests can control every roll. The Agent resolves each round as a single operation.

## Development

```sh
mix test                            # tests and doctests
mix test --cover                    # tests with coverage
mix format                          # format the code
mix format --check-formatted        # check the format
mix credo --strict                  # static analysis
mix dialyzer                        # type analysis (the first run takes a few minutes)
mix compile --warnings-as-errors    # compile, failing on warnings
```

CI runs these checks on pushes and pull requests to `main` and `develop`.

## Possible improvements

- Balance the moves: a player who only uses the average attack wins about 79% of games.
- Give the computer a strategy, for example not healing at full life.
- Support several games at once, with one process per game.
- Add a command line interface, so that IEx is not needed.
- Keep a history of results.

## Contributing

Please read the [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## License

[MIT](LICENSE)

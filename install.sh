#!/usr/bin/env bash
# ==============================================================================
#  Cabra Lattice — Autonomous Installer & Support Banner
#  "Compiling computational physics and herding AI agents since 2024"
# ==============================================================================

set -e

# Terminal colors (ANSI / Nord palette)
ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"

GOLD="${ESC}[38;5;221m"   # Horns (#ebcb8b)
WHITE="${ESC}[38;5;255m"  # Coat / Head (#eceff4)
CYAN="${ESC}[38;5;117m"   # Eyes / accents (#88c0d0)
GREEN="${ESC}[38;5;114m"  # Success (#a3be8c)
GRAY="${ESC}[38;5;244m"   # Borders / dim text

BTC_ADDR="bc1qklwq4pfcc6qhsd540zy35asdsvp5580f9h8a27"
ETH_ADDR="0xf1d2907F79A9B189D38EC4E48b6A27cFfD22F657"

clear_or_spacing() {
  if [ -t 1 ]; then
    printf "\n"
  fi
}

simulate_install() {
  clear_or_spacing
  printf "%b%b==>%b %bInstalling Cabra Lattice onto your system...%b\n\n" "$BOLD" "$CYAN" "$RESET" "$BOLD" "$RESET"
  
  steps=(
    "Resolving cabra-core dependencies"
    "Initializing Modern Fortran runtime"
    "Spawning 12 autonomous AI agents in Godot 4"
    "Allocating espresso reserves to /dev/heart"
  )

  for step in "${steps[@]}"; do
    printf "  %b•%b %-46s " "$GRAY" "$RESET" "$step..."
    sleep 0.25 2>/dev/null || sleep 1
    printf "%b%b✓ done%b\n" "$GREEN" "$BOLD" "$RESET"
  done
  printf "\n"
  sleep 0.3 2>/dev/null || true
}

print_logo() {
  # High-definition 256-color half-block render of Cabra (cabra.svg / favicon.svg)
  if command -v base64 >/dev/null 2>&1 && [ -z "${NO_COLOR:-}" ]; then
    base64 -d << 'EOF'
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OzU5beKWhBtbMzg7NTsyNTQ7NDg7NTsyNTVt4paEG1szODs1OzI1NW3iloQbWzQ4OzU7MjUybeKWhBtbMzg7NTsyNDM7NDg7NTsyNDBt4paEG1szODs1OzI1NTs0ODs1OzI0N23iloQbWzQ4OzU7MjU1beKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhBtbMzg7NTsyNDht4paEG1swbRtbN20bWzM4OzU7MjM4beKWhBtbMG0gICAgICAgICAbWzBtG1swbQogICAgICAgICAgICAgICAgICAgICAbWzdtG1szODs1OzI0Mm3iloQbWzBtG1szODs1OzI0MDs0ODs1OzI1NW3iloQbWzM4OzU7N23iloQbWzM4OzU7MjU1OzQ4OzU7MTg4beKWhBtbNDg7NTsyNTVt4paE4paE4paE4paE4paE4paE4paE4paE4paE4paE4paE4paE4paE4paEG1szODs1OzI1M23iloQbWzM4OzU7MjQ2beKWhBtbMzg7NTsyMzY7NDg7NTsyNTJt4paEG1swbRtbN20bWzM4OzU7MjM2beKWhBtbMG0gICAgICAgICAgG1swbRtbMG0KICAgICAgICAgICAgICAgICAgICAgICAgG1szODs1OzI0Mjs0ODs1OzI0MG3iloQbWzM4OzU7MjU0OzQ4OzU7MjQzbeKWhBtbMzg7NTsyNTE7NDg7NTsyNDZt4paEG1szODs1OzE0NTs0ODs1OzE0NW3iloQbWzM4OzU7MjQ2OzQ4OzU7MjUwbeKWhBtbMzg7NTsyMzU7NDg7NTsyNTFt4paEG1swbRtbN20bWzM4OzU7MjUxbeKWhBtbMzg7NTs3beKWhBtbMzg7NTsyNDlt4paEG1szODs1OzI0OG3iloQbWzM4OzU7MjQ2beKWhBtbMzg7NTsyNDRt4paEG1szODs1OzI0Mm3iloQbWzM4OzU7MjM5beKWhBtbMzg7NTsyMzdt4paEG1szODs1OzIzNG3iloQbWzBtICAgICAgICAgICAgIBtbMG0bWzBtCiAgICAgICAgICAgICAgICAgICAgICAgIBtbN20bWzM4OzU7MjM3beKWhBtbMG0bWzM4OzU7MjM5OzQ4OzU7MjQybeKWhBtbMzg7NTsyNTI7NDg7NTsyNTVt4paEG1szODs1OzIzOTs0ODs1OzI1NG3iloQbWzBtG1s3bRtbMzg7NTsyMzlt4paEG1swbSAgICAgICAgICAgICAgICAgICAgICAgIBtbMG0bWzBtCiAgICAgICAgICAgICAgICAgICAgICAgICAbWzdtG1szODs1OzIzNm3iloQbWzBtICAgICAgICAgICAgICAgICAgICAgICAgICAgG1swbRtbMG0KG1swbRtbPzI1aA==
EOF
  else
    cat << 'EOF'
               _          _               
             /   )      (   \             
            /   /        \   \            
     _      |  |          |  |      _     
   /   \    \   \        /   /    /   \   
  |     \____.-'""""""'-.____/     |  
   \________/            \________/   
           /   (o)    (o)   \          
          |        __        |         
           \      (..)      /          
            '.     --     .'           
              \   /||\   /             
                   \|/                 
EOF
  fi
}

print_banner() {
  print_logo
  cat << EOF

${BOLD}${WHITE}========================================================================${RESET}
${BOLD}${CYAN}                     C A B R A   L A T T I C E${RESET}
${GRAY}         Computational Physics • Modern Fortran • Godot 4 & AI${RESET}
${BOLD}${WHITE}========================================================================${RESET}

  ${GREEN}${BOLD}✓${RESET} ${BOLD}Package 'cabra' successfully installed in spirit.${RESET}

  To help keep the blog online, fund computational physics research,
  and keep the autonomous Godot swarm caffeinated:

  ${BOLD}BTC:${RESET}  ${GOLD}${BTC_ADDR}${RESET}
  ${BOLD}ETH:${RESET}  ${CYAN}${ETH_ADDR}${RESET}

${BOLD}${WHITE}========================================================================${RESET}
EOF
}

prompt_user() {
  local reply=""
  # When piped via curl (stdin is the script), read user input from /dev/tty
  if [ -t 1 ] && [ -r /dev/tty ]; then
    printf "\n${BOLD}Would you like to support Cabra? [Y/n]: ${RESET}"
    read -r reply < /dev/tty || reply="y"
  elif [ ! -t 0 ]; then
    read -r reply || reply="y"
  else
    printf "\n${GRAY}Visit https://cabra.pw for dispatches, essays, and physics notes.${RESET}\n\n"
    return 0
  fi

  case "$reply" in
    [nN]|[nN][oO])
      printf "\n"
      sleep 0.3 2>/dev/null || true
      printf "  ${GRAY}[*] Scanning local environment for cryptocurrency...${RESET}\n"
      sleep 0.3 2>/dev/null || true
      printf "  ${GRAY}[*] 0 BTC detected in your pockets.${RESET}\n"
      sleep 0.3 2>/dev/null || true
      printf "  ${GOLD}[!] Bleat protocol initiated: BAAAAAAAH! 🐐${RESET}\n"
      sleep 0.4 2>/dev/null || true
      printf "\n"
      printf "  ${BOLD}Just kidding! No hard feelings at all.${RESET}\n"
      printf "  ${DIM}(...Though if you happen to have 2 BTC lying around, the goat won't say no 😉)${RESET}\n\n"
      printf "  Thanks for checking out the project! Read more at: ${CYAN}https://cabra.pw${RESET}\n\n"
      ;;
    *)
      printf "\n"
      printf "  ${GREEN}${BOLD}Thank you so much for supporting open-source development! ☕🐐${RESET}\n\n"
      
      # Try clipboard helpers if present
      local copied=""
      if command -v wl-copy >/dev/null 2>&1; then
        echo -n "$BTC_ADDR" | wl-copy 2>/dev/null && copied="BTC"
      elif command -v xclip >/dev/null 2>&1; then
        echo -n "$BTC_ADDR" | xclip -selection clipboard 2>/dev/null && copied="BTC"
      elif command -v pbcopy >/dev/null 2>&1; then
        echo -n "$BTC_ADDR" | pbcopy 2>/dev/null && copied="BTC"
      fi

      if [ -n "$copied" ]; then
        printf "  ${CYAN}[✓] Copied ${copied} address to your clipboard!${RESET}\n"
      fi
      printf "  Blog & Swarm dispatches: ${CYAN}https://cabra.pw${RESET}\n\n"
      ;;
  esac
}

# Run sequence
simulate_install
print_banner
prompt_user

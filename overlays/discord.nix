self: super: {
  discord = super.discord.override { withOpenASAR = true; };
  discord-ptb = super.discord-ptb.override { withOpenASAR = true; };
  discord-canary = super.discord-canary.override { withOpenASAR = true; };
}

# Description
Tired of your legendary, high-skill archers missing critical shots or watching their arrows constantly scatter into walls, shields, or random obstacles? This mod completely overhauls the standard targeting mechanics for ranged weapons, turning your veteran marksmen into flawless, unblockable snipers.

# Installation instructions
copy the .zip file you've downloaded to `Battle Brothers\data`

# Main features
 - Perfect 100% Accuracy Display & Logic: When an eligible character targets an enemy, the game natively treats the action as non-hitchance dependent. The UI will cleanly display a 100% chance to hit, and internal combat dice rolls are automatically forced to succeed.

 - Smart Trajectory Bypass: Ranged shots will no longer go astray, get blocked by cover, or hit unintended targets. The mod temporarily tricks the tactical engine during the execution frame to process the attack instantly on your chosen target—completely ignoring physical blocking math while maintaining the visual projectile effect.

# Requirements
Modern Hooks (MSU)

# Known issue
 - Missed archer shots at 1 tile can fail to show an arrow projectile.
   Vanilla uses `SpawnProjectileMinDist = 2` (`data_001/scripts/config/character.nut`), so projectiles only render at distance 2+.
   This behavior is independent from the guaranteed-hit feature introduced by this mod.

# Special Thanks to 
 - enduriel
 - reforged
 - AI Gemini

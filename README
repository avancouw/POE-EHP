This directory contains a number of different scripts. You will find one script
for each type of build I've gotten around to analyzing.

These packages are written to be loaded into GNU Maxima, which is also provided
open source under the GNU GPL, and available to download on almost all platforms.
My quick-plot functions may not work on your platform, though. Contact me on the
forums at account 'Zakaluka' if you have questions that this README doesn't cover,
or if you need a script modified to account for some mechanic I skipped.

You may download GNU Maxima at: http://maxima.sourceforge.net/
The maxima manual has everything you need to learn this CAS. It's a very powerful
tool, but not quite as automated as a commercial CAS like mathematica or Maple.
As a result it's also a little more confusing. Like I said, if you contact me
I will try to help you get what you want out of this package.

----

The goal of each script is to generate a specific equation for effective health,
using the constants in set_defaults() which describe your build. Before you begin,
edit those constants to reflect your character. Certain constants are situational.
For instance, IRON_SKIN: 0 suggests that you wish to see EH plots without the
effects of an iron skin flask. mob_damage: 500 suggests you wish to see your EH
plot against an opponent that does 500 damage. Start with middle of the road
values, since you can easily re-assign these without starting over.

Each script defines a number of functions to calculate EH values and related
pieces of information, and other functions to provide quick plots. You don't
have to use the plot functions I've provided, though, as there are a lot of
other ways you could choose to look at the data.

All plots are in terms of stats from your gear, to make comparing trade-offs
easier. For instance, it should be possible for two overlapping evasion affixes
to add about 1100 evasion rating to an average hybrid evasion/armour piece at
max quality. This is why the axes will seem to be too short; a duelist wearing
hybrid armour can only get about 4000 evasion rating from gear alone, so that's
where the evasion axis ends. This value is converted internally into an actual
character-screen evasion rating, so don't get too wrapped up around that. We're
merely plotting against the values on your gear tooltips.

If you want to see what real evasion/armour a value on the axis corresponds to,
see the evasion_rating( gear_evasion ) and armour( gear_armour ) functions,
explained below.

Plots show a real EHP figure, not percent-EHP. This is relative to your total
health pool. Example:
you have a character with 2000 HP, and the EHP graph goes to 18,000.
that is 18000/2000 %EHP, or 900 percent total EHP.
Or, you've gained 800 percent EHP through defense.

Instructions:
-------------

A) set constants - under set_defaults(). Again, these don't have to be perfect,
   but make it mirror your build as much as possible. Good default values for
   mob_damage and mob_accuracy are 600 and 600. That's about right for a high
   level endgame map (>= 65).

B) fire up maxima. You'll get a pretty unfriendly-looking console screen.
   don't be afraid of it.

C) File - Batch File Silently
   Load the script that matches your defensive setup most closely.
   EHP_hybrid.mc - hybrid evasion/armour gear, with endurance. 

D) Even though you loaded "silently" you'll see a little noise from maxima's
   floating-point rationalizer, nothing to worry about. If you see any real error
   messages, let me know. If the print() function fails with an error, this
   doesn't matter. You'll see the environment (all your character's build constants)
   printed in the console window.

E) Call one of the provided plot functions. Find the name of your script below for
   a list.

F) Now you may wish to see how EH is affected by a changing situation. Suppose
   you encounter an %IPD aura monster pack and quickly drink an iron skin
   health flask:

   IRON_SKIN: 1;
   MOB_DAMAGE: 900;
   recalc();

   At this point you'll be spammed with screens full of math. Don't worry
   about it. That's just maxima re-solving for EH.

   now, call your plot function again. Again, see the next section to find
   its name.

   !!NOTE: any time you modify one of the constants, you have to call recalc().
   This is to re-generate the specific forms of your EHP functions.
   Like I said, maxima needs some guidance on how to solve complicated problems,
   this is why you have to manually re-substitute variables.

   Now, assume you want to see results for fighting a boss. Type the following:

   MOB_DAMAGE: 2000;
   GRANITE: 1;
   REFLEXES: 1;
   endurance: 5;       /* I eventually want a Kaom's to switch on during boss fights */
   recalc();

   Plot again and see how things change! You'll be surprised, no stat dominates in all
   situations, and any stat can become the optimal stat in one situation or another.

E) If you want to do something more advanced, you'll have to look through
   the code. It's not too terribly difficult to figure out. Please call
   up the online manual before coming to me for help. But failing that,
   I'll do what I can for you!

-----------------
SCRIPTS
-----------------

I: COMMON ROUTINES
set_defaults() - resets the defaults you've saved in your file.
display_global() - prints the values of all global constants.
reduction(armour, damage, endurance) - the general reduction equation.
chance_to_hit(accuracy, evasion_rating) - the general chance to hit equation.
total_life( gear_life ) - uses constants in the defaults() routine and applies them
	    to life on your gear to calculate your total life. Pass in gear_life.
	    affected by constants base_life, level, str, oak, bonus_life.
evasion_rating( gear_evasion ) - converts the evasion on your gear into character
            character screen evasion given the constants you have set. This is
	    affected by constants IER, REFLEXES, flask_IER.
armour( gear_armour ) - converts the armour on your gear into a total armour
	    rating. This is affected by constants IAR, GRANITE, IRON_SKIN, and flask_IAR.
reduction_cap_armour() - prints for you how much armour you need on gear to reach the
            reduction cap, given your global variables endurance and mob_damage.
reduction_cap_damage() - given the global MAX_GEAR_ARMOUR, which describes the maximum
            armour you could possibly have on gear given your chosen armour type, prints
	    for you how much damage would cap DR against the maximum possible armour.
	    This is mostly only useful for choosing a meaningful domain.
recalc() - re-generates your EH functions after changing a variable.
	    There are a number of expressions defined in this section that will
	    only be of interest to advanced users. If all you want is quick plots,
	    ignore the contents of this routine.

--------------
EHP_hybrid.mc: A duelist (or anyone for that matter) wearing evasion/armour hybrid gear.

plot_EH() - simple and straightforward, plots effective health against the possible
	  range of evasion/armour rating from gear.
plot_dEH() - plots the two partial derivatives of effective health. If you're not sure
	   what I mean: these two graphs will tell you how much EH you gain per point
	   of armour or evasion on your gear. These are interesting to look at, but
	   not really very useful; the next plot function is far more important.
plot_EH_per_affix() - Plots three surfaces:
	   (red) - EH gained for one perfect life affix
	   (green) - EH gained from each evasion affix in a trio of perfect overlapping evasion/armour affixes
	   (blue) - EH gained from each armour affix in a trio of perfect overlapping evasion/armour affixes
	   This is the most useful plot, because it tells you the real relative value of adding evasion vs armour
	   vs life.
plot_safe_max() - This one isn't completely done, but it kind of works. It's meant to suggest an armour value
           to use against very large bosses (still described by global) and show you the results against EH
	   if ALL of your other defensive budget goes towards evasion. Surprisingly enough, this appears to be
	   the most stat-efficient choice. Trouble is, you still need enough armour to be safe against those
	   large hits, so it chooses a safe enough armour value for you. It's a little bit interactive, though.
	   More on this one later. If you want to use it, details are near the bottom of recalc().

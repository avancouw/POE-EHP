/* Copyright 2012 by Aaron Van Couwenberghe
 * I don't care what you do with this package, so I'm posting it under the GPL, although that
 * should be pretty moot.
 *
 *    This file is part of the POE_EHP family of scripts for the Maxima computer algebra system.
 *
 *   POE_EHP is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Foobar is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Foobar.  If not, see <http://www.gnu.org/licenses/>. */

/* global parameters: one function to reset defaults, another to display current settings
   !!!!! USER: Call set_defaults to reset defaults */
set_defaults() := [
	/* Life stats */
	base_life: 50,		/* this doesn't change */
	level: 66,
	str: 306,
	gear_life: 265,		/* from mouseover tooltips, not your health globe */
	oak: 4,			/* number of times you've helped oak */
	increased_life: 93,	/* percent */
	bonus_life: 60,		/* flat life from passives */

	/* Enemy model */
	mob_accuracy: 600,
	mob_damage: 2500,
	mob_crit: 5,
	mob_mult: 150,

	/* Defense */
	endurance: 5,
	IAR: 112,
	IER: 110,
	block: 25,

	/* Flasks */
	flask_IAR: 100,
    	flask_IER: 100,

	/* Boolean flags */
	GRANITE: 1,
	IRON_SKIN: 1,
	REFLEXES: 1,
	INNER_FORCE: 0
];

/* General forms */
EH(life, reduction, chance_to_hit, block) :=
	life/((1-reduction)*chance_to_hit*(1-block/100));
reduction(armour, damage, endurance) :=
	armour / ( armour + 12 * damage ) + 0.05*endurance;
chance_to_hit( accuracy, evasion_rating ) :=
	accuracy / ( accuracy + ((evasion_rating/4)^0.8) );


/* Life vs gear template */
total_life( gear_life ) := 
	( base_life + 6*(level-1) + 0.5*str + gear_life + oak*45 + bonus_life )*( 1 + increased_life/100 );
/* Evasion rating vs gear template */
evasion_rating( gear_evasion ) :=
	gear_evasion * ( 1 + IER/100 + REFLEXES*flask_IER/100 );
/* Armour rating vs gear template */
armour( gear_armour ) :=
	( gear_armour + GRANITE*10000 ) * (1 + IAR/100 + IRON_SKIN*flask_IAR/100);

/* Utility functions */
/* under the current environment, with max gear, how much damage can we cap reduction against? */
reduction_cap_armour() := float(solve(0.9 = reduction(armour(gear_armour), mob_damage, endurance),
	gear_armour));
reduction_cap_damage() := float(solve(0.9 = reduction(armour(MAX_GEAR_ARMOUR), d, endurance), d));

/* Max budget constants
 * This should include your max planned level of Grace, if applicable
 * These maxes should account for your strategy. For instance, */
MAX_GEAR_EVASION:4301.6;
MAX_GEAR_ARMOUR:2404.8;

/* Per-affix values: "cost" of 1 defense affix is any other affix which
 * could have taken its place. How much rating do we gain per affix, so that
 * they may be compared by opportunity cost?
 * Put +100%AR/100%EV, 322 EV and 120 AR affixes on every item we're wearing
 * and see how much it would raise all of our defensive stats above base*20%qual.
 * 12 total affixes (neglecting shield, my build)
 * 4 item slots
 * EV_PER_AFFIX: EV_GAIN / 6
 * AR_PER_AFFIX: AR_GAIN / 6
 * EV_AR_RATIO: EV_PER_AFFIX / AR_PER_AFFIX
 * If you look to stack life on each slot, this affix combo is impossible;
 * instead suppose you wish to stack evasion mods.
 * Now, this time, you would have 8 total affixes on 4 item slots.
 * EV_PER_AFFIX would now still be close to EV_GAIN / 6 because we can't say that merely
 * half the % affix's gain goes towards evasion rating. */
QUAL_GEAR_EVASION:982.8;		/* gear numbers include flat rating on two rings */
QUAL_GEAR_ARMOUR:842.4;

EV_PER_AFFIX: (MAX_GEAR_EVASION - QUAL_GEAR_EVASION)/6;
AR_PER_AFFIX: (MAX_GEAR_ARMOUR - QUAL_GEAR_ARMOUR)/6;
LIFE_PER_AFFIX: 99;

EV_AR_RATIO:EV_PER_AFFIX/AR_PER_AFFIX;


/* !!!!! USER: Call display_global to display all global parameters */
display_global() := [
	print( "base_life:", base_life, "level:", level, "str:", str ),
	print( "gear_life:", gear_life, "oak:", oak, "increased_life:", increased_life ),
	print( "bonus_life:", bonus_life ),
	print( "mob_accuracy:", mob_accuracy, "mob_damage:", mob_damage ),
	print( "mob_crit:", mob_crit, "mob_mult:", mob_mult ),
	print( "endurance:", endurance, "IAR:", IAR, "IER:" = IER, "block:", block ),
	print( "flask_IAR:", flask_IAR, "flask_IER:", flask_IER ),
	print( "GRANITE:", GRANITE, "IRON_SKIN:", IRON_SKIN, "REFLEXES:", REFLEXES ),
	print( "INNER_FORCE:", INNER_FORCE )
];


/* !!!!! USER: call this function whenever the environment changes.
   !!!!! Re-calculate the specific forms of EH and all its forms */
recalc() := [
	/* --------------------- */
	/* Crit-adjusted defense */
	/* --------------------- */
	mob_crit_damage: mob_damage * mob_mult / 100,
	average_damage_unmitigated: mob_damage * (( 1 - mob_crit/100 ) + ( mob_crit/100 )*mob_mult/100 ),

	/* First, a form for reduction with a crit, and reduction with a non-crit */
	noncrit_DR: ev( reduction( a, mob_damage, endurance ), a = armour( gear_armour )),
	crit_DR: ev( reduction( a, mob_crit_damage, endurance ), a = armour( gear_armour )),

	/* Now mitigate the non-crit and the crit */
	mit_noncrit: mob_damage * ( 1 - noncrit_DR ),
	mit_crit: mob_crit_damage * ( 1 - crit_DR ),

	/* Now average them together, no avoidance */
	average_damage_mitigated: mit_noncrit * ( 1 - mob_crit / 100 ) + mit_crit * mob_crit / 100,

	/* 3 different things can happen when the mob swings. */
	/* miss_probability: 1 - chance_to_hit( accuracy, evasion_rating ),
	 * miss_probability isn't actually used */
	crit_probability: chance_to_hit( mob_accuracy, evasion_rating )^2 * mob_crit / 100,
	hit_probability: chance_to_hit( mob_accuracy, evasion_rating ) - crit_probability,

	/* Weighted average damage including effects of crit and evasion */
	total_average_damage: mit_noncrit * hit_probability + mit_crit * crit_probability,

	/* evr_ratio is the total percentage of damage which passes by defenses
	 * ONLY armour, evasion rating, and endurance are considered. Blind may
	 * give incorrect results. */
	evr_ratio: total_average_damage / average_damage_unmitigated,

        /* ------------------- */
	/* Specific form of EH */
	/* ------------------- */
	/* Iterative substitution */
	/* We've combined reduction and evasion, so force reduction = 1-evr_ratio and chance_to_hit=1.
	 * ev_mit_ratio includes all defense stats */
	h1: ev( EH(l, r, c, b), l = life, r = 1 - evr_ratio, c = 1, b = block ),
	/* General form of EH */
	EHG: ev( h1, life = total_life(gear_life), armour = armour(gear_armour),
		evasion_rating = evasion_rating(gear_evasion)),
	/* Substitute remaining variables in environment and simplify */
	EHS: ev(EHG),
	/* Re-evaluate EHS if you change the environment */

	/* +99 life affix function */
	l1: ev( h1, life = total_life(gear_life + LIFE_PER_AFFIX),
		armour = armour(gear_armour), evasion_rating = evasion_rating(gear_evasion)),
	EH_delta_life: ev( l1 ),

	/* EH per point evasion rating */
	dEH_dEV:  derivative( EHS, gear_evasion ),
	/* EH per point armour rating */
	dEH_dAR:  derivative( EHS, gear_armour ),
	/* per-budget EH equivalence (implicit_plot hangs) */
	equiv: dEH_dEV * ratio = dEH_dAR,

	/* Determine domain */
	
	A: reduction_cap_armour(),
	CAP_ARMOUR: ev( gear_armour, A ),
	MAX_ARMOUR: min( CAP_ARMOUR, MAX_GEAR_ARMOUR ),
	/* MAX_ARMOUR: MAX_GEAR_ARMOUR, */

	/* EH per affix */
	EH_per_life_affix: EH_delta_life - EHS,
	EH_per_evasion_affix: ev( EHS, gear_evasion = gear_evasion + EV_PER_AFFIX ) - EHS,
	EH_per_armour_affix: ev( EHS, gear_armour = gear_armour + AR_PER_AFFIX ) - EHS,

	/* scale, should display on axis but doesn't */
	EHD_min_life: round(ev( EH_per_life_affix, gear_armour = 0, gear_evasion = 0 )),
	EHD_max_life: round(ev( EH_per_life_affix, gear_armour = MAX_ARMOUR, gear_evasion = MAX_GEAR_EVASION )),
	EHD_min_armour: round(ev( EH_per_armour_affix, gear_armour = 0, gear_evasion = 0 )),
	EHD_max_armour: round(ev( EH_per_armour_affix, gear_armour = MAX_ARMOUR, gear_evasion = MAX_GEAR_EVASION )),
	EHD_min_evasion: round(ev( EH_per_evasion_affix, gear_armour = 0, gear_evasion = MAX_GEAR_EVASION )),
	EHD_max_evasion: round(ev( EH_per_evasion_affix, gear_armour = MAX_ARMOUR, gear_evasion = 0 )),

	/* "safe" armour rating */
	/* I feel "safe" with a 25% hit, because then I can survive a crit
         * immediately following it. */
	safe_percent: 25,
	safe_mitigated: (safe_percent / 100)*total_life(gear_life),
	C1: ev( mob_damage = safe_mitigated/(1-r), r=reduction(armour(gear_armour), mob_damage, endurance )),
	C2: float( solve( C1, gear_armour ) ),
	safe_armour: max( ev( gear_armour, C2 ), 0 ),
	EH_safe_armour: ev( EHS, gear_armour=safe_armour ),

	/* how large is the hit */
	C3: ev( r = reduction(armour(safe_armour), d, endurance), d=safe_mitigated/(1-r)),
	C4: float( solve( C3, r ))[1],
	safe_mob_damage: safe_mitigated / (1 - ev( r, C4 )),
	safe_hit_percent: safe_mitigated * 100 / total_life( gear_life ),
	large_crit_damage: safe_mob_damage * mob_mult/100,
	large_crit_percent: 100*large_crit_damage*(1- reduction(armour(safe_armour), large_crit_damage, endurance))/total_life(gear_life),
	
	/* Warn if the crit is too large */
	if (( 100 - safe_hit_percent - large_crit_percent ) < safe_percent/2 ) then
		[ print("A crit can leave you unsafe. Adjust your safety margin or lower crit damage %"),
		  print("safe_hit_percent", safe_hit_percent, "large_crit_percent", large_crit_percent,
			"mob_mult", mob_mult) ]
	

];

/* Set environment for substitution, and calculate EH with defaults */
set_defaults();
recalc();

/* Print some information about the environment */
display_global();

plot_EH() :=
	/* Determine gear_armour for capped DR, to set max scale.
	 * if DR caps when reduction_cap_armour < MAX_GEAR_ARMOUR, plot to reduction_cap_armour
	 * otherwise plot to MAX_GEAR_ARMOUR */
	plot3d(EHS, [gear_armour, 0, MAX_ARMOUR], [gear_evasion, 0, MAX_GEAR_EVASION]);

plot_dEH() :=
	plot3d([[dEH_dAR,[gear_armour,0,MAX_ARMOUR],[gear_evasion,0,MAX_GEAR_EVASION]], dEH_dEV,
		[gear_armour, 0, MAX_ARMOUR], [gear_evasion, 0, MAX_GEAR_EVASION]]);

plot_EH_per_affix() := [
	print("EH per Life affix (red plot): min", EHD_min_life, "max", EHD_max_life),
	print("EH per Armour affix (blue plot): min", EHD_min_armour, "max", EHD_max_armour),
	print("EH per Evasion affix (green plot): min", EHD_min_evasion, "max", EHD_max_evasion),
	print("Top of the armour scale is", MAX_ARMOUR, "from gear."),
	print("If that figure is below", MAX_GEAR_ARMOUR),
	print("then the top of the scale represents capped reduction."),
	
	plot3d([EH_per_life_affix,
		EH_per_evasion_affix,
		EH_per_armour_affix,
		[ gear_armour, 0, MAX_ARMOUR ], [ gear_evasion, 0, MAX_GEAR_EVASION ]
	],
	[legend, ["life: red", "evasion: green", "armour: blue"]],
	[palette, [hue, 0.85, 0.7, 0.8, 0.2], [hue, 0.25, 0.7, 0.8, 0.2], [hue, 0.6, 0.7, 0.8, 0.2]],
	[plot_format, xmaxima])		  
];

plot_safe_max() := [ print("safe armour from gear against this hit size:", safe_armour),
		plot2d(EH_safe_armour, [gear_evasion, 0, MAX_GEAR_EVASION])];

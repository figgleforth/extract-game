## extract-game

An extraction game where the world is built stochastically rather than authored. Elevation, water,
tree density, steepness, and movement cost all emerge from generated matrices layered on top of
each other, and derived layers (compounds, compound heatmaps) grow out of the base terrain rather
than being hand-placed.

Entities inhabiting this world are math-driven, not scripted: their behavior comes from reacting to
the values in these layers (sensory input, movement cost, compound signals) rather than fixed
routines. The result should feel closer to a simulation than a level.

Loosely inspired by Hunt: Showdown's tension — sense clues, close in, extract.

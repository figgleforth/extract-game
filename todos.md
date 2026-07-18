_Collected from codebase by Claude_

## Todo

- [game.gd] stop manually placing nodes in main.tscn. Instead, rename this to Main, main.rb, and programmatically add all the matrix nodes.
- [game.gd] write base generator that they can inherit from. They all implement generate() or something like that, which is called when in _ready(). The generate() can be aliased with regenerate() to basically override the generation.
- [game.gd] clean up this stinky generate_matrix API
- [steepness.gd] do this in movement_cost instead
- [compound_heatmap.gd] entities should have their own heatmap that dynamically changes based on the compound the entity is interested in. Maybe even blended with the world heatmap, where the other compounds are faded, so the entity would still know where there's a compound.

## Done

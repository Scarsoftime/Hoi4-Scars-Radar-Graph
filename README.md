# Hoi4-Scars-Radar-Graph

![Demo](https://imgur.com/AO61d0D.gif)

Implements a radar graph chart into Hearts of Iron IV via the use of shaders. I made two versions, a static single element version and an animated sector-specific element that is capable of transitioning smoothly between an initial and a final state.
## Non-animated version
Located in `gfx/FX/radar_graph_5axis.shader`, this version takes in a square sprite and creates the pentagon shape dynamically according to its input. A scripted effect has been setup in `common/scripted_effects/hoi4_radar_graph_core.txt` to process its input, `calculate_radar_graph_5axis_frame`, where the input is a five-element temp array called `axis`, expecting values between 0-1.. It uses bit-packing to encode the data of all 5 axes into a single variable that can be fed to a variable as a `frame` argument in the scripted GUI.

## Animated version
Located in `gfx/FX/radar_graph_5axis_anim.shader`, the implementation for this varies slightly as this shader expects there to be five separate elements representing the five sectors of triangles between two axes, setup in a gridbox as shown in the GUI. The scripted effect `calculate_radar_graph_5axis_anim_frame` expects two arrays of five elements, `axis_init` and `axis_final`, and generates an output temp array called `sector_frame` that can be assigned to another array to be fed into five elements, each rendering a sector between two axes. The scripted GUI has implemented this using a dynamic list. It uses a `_click_enabled` toggle at each element to fire the animation at will, with this implementation using the country flag `radar_graph_5axis_anim_toggle`.

Note: Due to limitations of how much data can be fed into the shader, the animated version is the most extendable if we want to create a radar graph with more axes.

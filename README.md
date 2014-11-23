MetalReactionDiffusion
======================

![iPad Screen Shot](http://flexmonkey.co.uk/ipad_reaction_diffusion.png)

ReDiLab is an application for running reaction diffusion simulations: models which explain how the concentration of one or more substances distributed in space changes under the influence of two processes: local chemical reactions in which the substances are transformed into each other, and diffusion which causes the substances to spread out over a surface in space.

Reaction diffusion systems can exhibit spontaneous pattern formation such as stripes, spots and spirals and were famously first theorised by Alan Turing in his paper, "The Chemical Basis of Morphogenesis".

Version 1 includes Belousov-Zhabotinsky, FitzHugh-Nagumo and Gray-Scott models which are accessed via the hamburger menu in the right hand detail panel.

Parameters are changed via the horizontal sliders in the right hand panel. For finer control, a long-press on a slider pops up another wider slider. When the wider slider is changed, the simulation automatically resets. 

Configurations can be saved, along with a thumbnail image, with the "save" button in the pop up menu. From the menu, you can also access the "browse and load" dialog. A long-press on any of the preset configurations in the "browse and load" dialog pops up an option to delete. If you delete by accident, don't worry - simply switch on "show recently deleted" and the pop up on deleted configurations now displays "undelete".

ReDiLab is an open source application and its source code is available here: https://github.com/FlexMonkey/MetalReactionDiffusion. It is written in Apple's Swift language and uses the Metal framework. Because it uses Metal, ReDiLab requires an iPad with an A7 or better CPU.

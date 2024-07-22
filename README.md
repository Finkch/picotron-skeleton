# picotron-skeleton

A library for animating skeletons in the Picotron fantasy workstation.  
Each component of a skeleton has a `:pod()` method. When called on the skeleton, it will recurse down each of its components, returning a table that be turned into a POD object. This can be used to move skeletons around between projects, or to editors such as [necrodancer](https://github.com/Finkch/picotron-necrodancer).  
This library requires an external library called `lib` that contains `vec.lua` and `tstr.lua`. `tstr.lua` can be found at [finkchutil](https://github.com/Finkch/picotron-finkchutil), and both can be found in the [necrodancer](https://github.com/Finkch/picotron-necrodancer) repository.  


## skeleton.lua

`skeleton.lua` defines a set of bones to comprise a skeleton as well as a set of animations stored in an animator class (called necromancer).  
By calling a skeleton's `:update()` method, the animation frame is updated, moving its animation along. Skeletons are drawn through their `:draw()` method; this isn't fully implemented (will eventually texture map onto the bones), but for now will draw joints and lines if debug mode is on.  
While a skeleton has an `:add()` and `:remove()` method to adjust their bones at runtime, these should not be used. They do not update the necromancer or its keyframes, which will crash animations. These are used by skeleton editing software. Rather, the correct way to build a skeleton it to create a series of bones; start with the `core` and attach children to it. Then, pass the `core` to the skeleton.  


## bone.lua

`bone.lua` defines a single bone in a skeleton. The `bone` parameter is a vector that points from the `joint` parameter to the tip of the bone; both are 2D vectors. The `z` parameter is the depth of the bone, used for draw order (which is currently inimplemented).  
A bone's `transform` is used by the necromancer to set the current pose for the current animation. In the skeleton's resting state, its transform will be zeroes.  
When creating a skeleton, a `core` bone is specified and children are added to their parent bones. The structure on a skeleton is effectively a tree. To add a child bone to a parent bone, use the bone's `:add()` method.  


## necromancer.lua

`necromancer.lua` is in charge of running the skeleton's animations. It tracks the current frame, grabs the current keyframes, interpolates between keyframes given the progress through current frame, and so forth. A necromancer is effectively an array of animations, a frame counter, and a bit of logic.  
To set the current animation, use the necromancer's `:set()` method.  
Currently, necromancers use linear interpolation. Soon (when I get around to implementing it), they will learn more complex magics and interpolation algorithms.  


## animation.lua

`animation.lua` defines animations. A series of keyframes with some information about when each appears during the animation. To create an animation, create an ordered array of keyframes and use it to create an animation instance.  


## keyframe.lua

`keyframe.lua` defines a single pose within an animation. Each keyframe has a table of transforms that dictate the rotational and positional change from the skeleton's resting pose and the desired pose. It also has a duration, the number of frames until the next keyframe.  


## transform,lua

`transform.lua` describes–you guessed it–transforms. A transform consists of a position vector and an angle. These are relative to the skeleton's resting pose. The position affects the joint position of a bone and the angle is its angle relative to its parent bone.  
Transforms can be mathematically added together. Transforms can be multiplied with scalar numbers (used for interpolation) or with vectors (to transform the vector). For both cases of multiplication, the transform has to be on the left-hand side of the multiplication operator.  
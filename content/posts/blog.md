+++
title = "A Blog post for Charlotte A different post"
author = ["Oliver Pauffley"]
date = 2023-01-13
draft = false
+++

## Test blog post {#test-blog-post}

Here is some code I wrote today:

```haskell
foldTree :: (a -> b -> b) -> b -> BinaryTree a -> b
foldTree _ b Leaf                = b
foldTree f b (Node left a right) =  foldTree f (foldTree f (f a b) left) right
```


### Does it do images? {#does-it-do-images}

[drawing](/ox-hugo/IMG_20231011_170658130.jpg)
[image](/ox-hugo/IMG_20231011_170658130.jpg)


## Another post? {#another-post}

Does this work?


[//]: # "Exported with love from a post written in Org mode"
[//]: # "- https://github.com/kaushalmodi/ox-hugo"

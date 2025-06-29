;;; A AE2 <--> Powah autocrafting setup.

;; Item names
(local iron "minecraft:iron_ingot")
(local gold "minecraft:gold_ingot")
(local blazeRod "minecraft:blaze_rod")
(local blazeRodBlock "allthecompressed:blaze_rod_block")
(local diamond "minecraft:diamond")
(local emerald "minecraft:emerald")
(local star "minecraft:nether_star")
(local redstoneBlock "minecraft:redstone_block")

(local energizedSteel "powah:steel_energized")
(local blazingCrystal "powah:crystal_blazing")
(local blazingCrystalBlock "powah:blazing_crystal_block")
(local nioticCrystal "powah:crystal_niotic")
(local spiritedCrystal "powah:crystal_spirited")
(local nitroCrystal "powah:crystal_nitro")

(local state {:orb nil :in nil :out nil})
(var loopCraft nil)

(fn grabItems []
  (let [slots (state.orb.list)]
    (when (next slots)
      (let [idx (next slots)]
        (state.orb.pushItems (peripheral.getName state.out) idx)
        (grabItems)))))

(fn find-index [tbl predicate-fn]
  (accumulate [idx nil k v (pairs tbl)]
    (if (predicate-fn v) k idx)))

(fn waitForCraft [targetItem]
  (match (find-index (state.orb.list) (fn [item] (= item.name targetItem)))
    nil (do
          (sleep 0.2)
          (waitForCraft targetItem))
    _ (do
        (grabItems)
        (loopCraft))))

(fn craft [inputs output]
  (each [_ item (ipairs inputs)]
    (let [idx (find-index (state.in.list) (fn [e] (= e.name item.name)))]
      (when idx
        (state.in.pushItems (peripheral.getName state.orb) idx item.count))))
  (waitForCraft output))

(fn craft-nothing []
  (sleep 0.2)
  (loopCraft))

(fn get-names [tbl]
  (let [names {}]
    (each [_ e (pairs tbl)]
      (tset names e.name true))
    names))

(fn has_all? [names required]
  (accumulate [result true _ name (ipairs required)]
    (and result (. names name))))

(local crafting-rules [{:inputs [{:name iron :count 1} {:name gold :count 1}]
                        :output energizedSteel}
                       {:inputs [{:name blazeRod :count 1}]
                        :output blazingCrystal}
                       {:inputs [{:name blazeRodBlock :count 1}]
                        :output blazingCrystalBlock}
                       {:inputs [{:name diamond :count 1}]
                        :output nioticCrystal}
                       {:inputs [{:name emerald :count 1}]
                        :output spiritedCrystal}
                       {:inputs [{:name star :count 1}
                                 {:name redstoneBlock :count 2}
                                 {:name blazingCrystalBlock :count 1}]
                        :output nitroCrystal}])

(fn get-item-count [inventory name]
  (var total 0)
  (each [_ item (pairs inventory)]
    (when (= item.name name)
      (set total (+ total item.count))))
  total)

(fn can-craft? [inventory recipe]
  (var craftable true)
  (each [_ input (ipairs recipe.inputs)]
    (let [avalabe (get-item-count inventory input.name)]
      (when (< avalabe input.count)
        (set craftable false))))
  craftable)

(fn craftable-recipes [inventory recipes]
  (let [craftable []]
    (each [_ recipe (ipairs recipes)]
      (when (can-craft? inventory recipe)
        (table.insert craftable recipe)))
    craftable))

(fn dispatch-craft [inventory]
  (var to-craft nil)
  (each [_ recipe (ipairs crafting-rules)]
    (when (and (not to-craft) (can-craft? inventory recipe))
      (set to-craft recipe)))
  (if to-craft
      (do
        (print (.. "Crafting: " to-craft.output))
        (craft to-craft.inputs to-craft.output))
      (craft-nothing)))

(set loopCraft (fn []
                 (let [contents (state.in.list)]
                   (dispatch-craft contents))))

(fn init-peripherals []
  (set state.orb (peripheral.find "powah:energizing_orb"))
  (set state.in (peripheral.find "sophisticatedstorage:chest"))
  (set state.out (peripheral.find "ae2:pattern_provider")))

(fn check-peripherals []
  (print "=== State Initialization Check ===")
  (print (.. "orb: " (if state.orb (tostring state.orb) "NOT INITIALIZED")))
  (print (.. "in: " (if state.in (tostring state.in) "NOT INITIALIZED")))
  (print (.. "out: " (if state.out (tostring state.out) "NOT INITIALIZED")))
  (let [all-initialized (and state.orb state.in state.out)]
    (print (.. "All components initialized: " (if all-initialized :YES :NO)))
    all-initialized))

(fn main []
  (do
    (print "Starting Powah Autocrafting!")
    (init-peripherals)
    (check-peripherals)
    (grabItems)
    (loopCraft)))

(main)

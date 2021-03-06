#define RAD_LEVEL_LOW 0.01 // Around the level at which radiation starts to become harmful
#define RAD_LEVEL_MODERATE 10
#define RAD_LEVEL_HIGH 25
#define RAD_LEVEL_VERY_HIGH 50

//Geiger counter
//Rewritten version of TG's geiger counter
//I opted to show exact radiation levels

/obj/item/device/geiger
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation in an area."
	icon_state = "geiger_off"
	item_state = "multitool"
	w_class = ITEMSIZE_SMALL
	var/scanning = 0
	var/radiation_count = 0

/obj/item/device/geiger/New()
	processing_objects |= src

/obj/item/device/geiger/Destroy()
	processing_objects -= src
	return ..()

/obj/item/device/geiger/process()
	get_radiation()

/obj/item/device/geiger/proc/get_radiation()
	if(!scanning)
		return
	radiation_count = radiation_repository.get_rads_at_turf(get_turf(src))
	update_icon()

/obj/item/device/geiger/examine(mob/user)
	..(user)
	get_radiation()
	to_chat(user, "<span class='warning'>[scanning ? "Ambient" : "Stored"] radiation level: [radiation_count ? radiation_count : "0"]Bq.</span>")

/obj/item/device/geiger/rad_act(amount)
	if(!amount || !scanning)
		return FALSE

	if(amount > radiation_count)
		radiation_count = amount

	var/sound = "geiger"
	if(amount < 5)
		sound = "geiger_weak"
	playsound(src, sound, between(10, 10 + (radiation_count * 4), 100), 0)
	if(sound == "geiger_weak") // A weak geiger sound every two seconds sounds too infrequent.
		spawn(1 SECOND)
			playsound(src, sound, between(10, 10 + (radiation_count * 4), 100), 0)
	update_icon()

/obj/item/device/geiger/attack_self(var/mob/user)
	toggle()

/obj/item/device/geiger/AltClick()//ECLIPSE EDIT
	toggle()

/obj/item/device/geiger/proc/toggle(var/mob/user)//Moved here to easy the alt click process
	if(!isliving(usr))
		return 0
	scanning = !scanning
	update_icon()
	to_chat(user, "<span class='notice'>\icon[src] You switch [scanning ? "on" : "off"] \the [src].</span>")

/obj/item/device/geiger/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1

	switch(radiation_count)
		if(null)
			icon_state = "geiger_on_1"
		if(-INFINITY to RAD_LEVEL_LOW)
			icon_state = "geiger_on_1"
		if(RAD_LEVEL_LOW to RAD_LEVEL_MODERATE)
			icon_state = "geiger_on_2"
		if(RAD_LEVEL_MODERATE to RAD_LEVEL_HIGH)
			icon_state = "geiger_on_3"
		if(RAD_LEVEL_HIGH to RAD_LEVEL_VERY_HIGH)
			icon_state = "geiger_on_4"
		if(RAD_LEVEL_VERY_HIGH to INFINITY)
			icon_state = "geiger_on_5"

#undef RAD_LEVEL_LOW
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
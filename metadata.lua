return PlaceObj('ModDef', {
	'title', "Rolling Shifts",
	'description', "Implements rolling shifts.\n\nOn every shift change, looks for colonists that are unhappy with where they are working (outside, or night shift), and attempts to swap them with the happiest colonist of the same speciality.\n\nThis is mostly a proof-of-concept, as it doesn't care about what dome the other colonist is in, if either of the colonists have the right speciality for the work they're doing, if there's any transport to get the two colonists to swap spots, or any one of a number of other things.\n\nPresuming that your domes are sufficiently connected; passages, all domes withing working range, or shuttles, it will probably be an overall win, as this only addresses colonists who are notably unhappy once per shift.\n\nAlso note that you will almost certainly need to have at least one geologist working an indoor job for this mod to do anything to them, as mines count as bad workplaces for all shifts.\n\nPermission is granted to update this mod to support the latest version of the game if I'm not around to do it myself.",
	'last_changes', "Switch to table.sortby_field/_descending, as it should be a little faster than table.sort",
	'id', "XGKbJee",
	'steam_id', "1814314655",
	'pops_desktop_uuid', "c614234b-bdf1-43a1-8dd0-f1f770903bb8",
	'pops_any_uuid', "523fb074-e3cd-4912-bc91-1fe8a8bd4171",
	'author', "mrudat",
	'version_minor', 1,
	'version', 19,
	'lua_revision', 233360,
	'saved_with_revision', 245618,
	'code', {
		"Code/RollingShifts.lua",
	},
	'saved', 1565609005,
})
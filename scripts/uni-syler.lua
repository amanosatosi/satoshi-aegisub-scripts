-- Automation 4 demo script
-- uni ကို syl form ပြောင်းတယ်

local tr = aegisub.gettext

script_name = tr("Uni Syler")
script_description = tr("others:NOOOO you can't add effects with unicode. me:haha. uni syler go brrrrrrrr")
script_author = "Amano Satoshi"
script_version = "1"

include("unicode.lua")


lookup = {
  ['က'] = '{\\k0}က', 
  ['ခ'] = '{\\k0}ခ', 
  ['ဂ'] = '{\\k0}ဂ', 
  ['ဃ'] = '{\\k0}ဃ', 
  ['င'] = '{\\k0}င', 
  ['စ'] = '{\\k0}စ', 
  ['ဆ'] = '{\\k0}ဆ', 
  ['ဇ'] = '{\\k0}ဇ', 
  ['ဈ'] = '{\\k0}ဈ', 
  ['ည'] = '{\\k0}ည', 
  ['ဋ'] = '！', 
  ['ဌ'] = '！', 
  ['ဍ'] = '！', 
  ['ဎ'] = '！', 
  ['ဏ'] = '{\\k0}ဏ', 
  ['တ'] = '{\\k0}တ', 
  ['ထ'] = '{\\k0}ထ', 
  ['ဒ'] = '{\\k0}ဒ', 
  ['ဓ'] = '{\\k0}ဓ', 
  ['န'] = '{\\k0}န', 
  ['ပ'] = '{\\k0}ပ', 
  ['ဖ'] = '{\\k0}ဖ', 
  ['ဗ'] = '{\\k0}ဗ', 
  ['ဘ'] = '{\\k0}ဘ', 
  ['မ'] = '{\\k0}မ', 
  ['ယ'] = '{\\k0}ယ', 
  ['ရ'] = '{\\k0}ရ', 
  ['လ'] = '{\\k0}လ', 
  ['ဝ'] = '{\\k0}ဝ', 
  ['သ'] = '{\\k0}သ', 
  ['ဟ'] = '{\\k0}ဟ', 
  ['ဠ'] = '！', 
  ['အ'] = '{\\k0}အ', 
  ['A'] = '{\\k0}A', 
  ['B'] = '{\\k0}B', 
  ['C'] = '{\\k0}C', 
  ['D'] = '{\\k0}D', 
  ['E'] = '{\\k0}E', 
  ['F'] = '{\\k0}F', 
  ['G'] = '{\\k0}G', 
  ['H'] = '{\\k0}H', 
  ['I'] = '{\\k0}I', 
  ['J'] = '{\\k0}J', 
  ['K'] = '{\\k0}K', 
  ['L'] = '{\\k0}L', 
  ['M'] = '{\\k0}M', 
  ['N'] = '{\\k0}N', 
  ['O'] = '{\\k0}O', 
  ['P'] = '{\\k0}P', 
  ['Q'] = '{\\k0}Q', 
  ['R'] = '{\\k0}R', 
  ['S'] = '{\\k0}S', 
  ['T'] = '{\\k0}T', 
  ['U'] = '{\\k0}U', 
  ['V'] = '{\\k0}V', 
  ['W'] = '{\\k0}W', 
  ['X'] = '{\\k0}X', 
  ['Y'] = '{\\k0}Y', 
  ['Z'] = '{\\k0}Z', 
  ['a'] = '{\\k0}a', 
  ['b'] = '{\\k0}b', 
  ['c'] = '{\\k0}c', 
  ['d'] = '{\\k0}d', 
  ['e'] = '{\\k0}e', 
  ['f'] = '{\\k0}f', 
  ['g'] = '{\\k0}g', 
  ['h'] = '{\\k0}h', 
  ['i'] = '{\\k0}i', 
  ['j'] = '{\\k0}j', 
  ['k'] = '{\\k0}k', 
  ['l'] = '{\\k0}l', 
  ['m'] = '{\\k0}m', 
  ['n'] = '{\\k0}n', 
  ['o'] = '{\\k0}o', 
  ['p'] = '{\\k0}p', 
  ['q'] = '{\\k0}q', 
  ['r'] = '{\\k0}r', 
  ['s'] = '{\\k0}s', 
  ['t'] = '{\\k0}t', 
  ['u'] = '{\\k0}u', 
  ['v'] = '{\\k0}v', 
  ['w'] = '{\\k0}w', 
  ['x'] = '{\\k0}x', 
  ['y'] = '{\\k0}y', 
  ['z'] = '{\\k0}z',
  ['('] = '{\\k0}(',
  [')'] = '{\\k0})',
  ['၏'] = '{\\k0}၏',






	
	
	
}

function make_fullwidth(subtitles, selected_lines, active_line)
	for z, i in ipairs(selected_lines) do
		local l = subtitles[i]
		
		aegisub.debug.out(string.format('Processing line %d: "%s"\n', i, l.text))
		aegisub.debug.out("Chars: \n")
		
		local in_tags = false
		local newtext = ""
		for c in unicode.chars(l.text) do
			aegisub.debug.out(c .. ' -> ')
			if c == "{" then
				in_tags = true
			end
			if in_tags then
				aegisub.debug.out(c .. " (ignored, in tags)\n")
				newtext = newtext .. c
			else
				if lookup[c] then
					aegisub.debug.out(lookup[c] .. " (converted)\n")
					newtext = newtext .. lookup[c]
				else
					aegisub.debug.out(c .. " (not found in lookup)\n")
					newtext = newtext .. c
				end
			end
			if c == "}" then
				in_tags = false
			end
		end
		
		l.text = newtext
		subtitles[i] = l
	end
	aegisub.set_undo_point(tr"uni syler")
end 

aegisub.register_macro(tr"uni syler", tr"Convert Latin letters to SJIS fullwidth letters", make_fullwidth)


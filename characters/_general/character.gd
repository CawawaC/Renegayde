extends Sprite

export (Texture) var default
export (Texture) var ashamed
export (Texture) var pumped
export (Texture) var bruised
export (Texture) var fine
export (Texture) var misinformed
export (Texture) var trueInfo
export (Texture) var nottalked
export (Texture) var impressed
export (Texture) var unimpressed
export (Texture) var foolish
export (Texture) var interested
export (Texture) var annoyed

func _ready():
	var e = Game.char_emotions[name]
	apply_emotion(e)

func apply_emotion(emotion):
	var e_pic = get(emotion)
	if e_pic == null:
		e_pic = default
	
	texture = e_pic
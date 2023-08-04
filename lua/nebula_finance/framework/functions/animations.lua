function NebulaFinance:LerpColor(t, from, to)
    return Color(Lerp(t, from.r, to.r), Lerp(t, from.g, to.g), Lerp(t, from.b, to.b), Lerp(t, from.a, to.a))
end

function NebulaFinance:Ease(t, b, c, d)
    t = t / d
    local ts = t * t
    local tc = ts * t

    return b + c * (9.3475 * tc * ts + -22.6425 * ts * ts + 15.495 * tc + -1.3 * ts + 0.1 * t)
end

local PANEL = FindMetaTable("Panel")

function PANEL:LerpColor(var, to, duration, callback)
	local duration = duration or .4
	local color = self[var]
	local anim = self:NewAnimation(duration)
	anim.Color = to

	anim.Think = function(anim, pnl, fract)
		local newFract = NebulaFinance:Ease(fract, 0, 1, 1)

		if (!anim.StartColor) then
			anim.StartColor = color
		end

		local newColor = NebulaFinance:LerpColor(newFract, anim.StartColor, anim.Color)
		self[var] = newColor
	end
	
	anim.OnEnd = function()
		if callback then
			callback(self)
		end
	end
end

function PANEL:AnimateSize(w, h, duration, callback)
	local anim = self:NewAnimation(duration)
	anim.Size = Vector(w, h)

	anim.Think = function(anim, pnl, fract)
		local newFract = NebulaFinance:Ease(fract, 0, 1, 1)

		if (!anim.StartSize) then
			anim.StartSize = Vector(pnl:GetWide(), pnl:GetTall(), 0)
		end

		local new = LerpVector(newFract, anim.StartSize, anim.Size)
		self:SetSize(new.x, new.y)
	end

	anim.OnEnd = function()
		self.IsAnimating = false

		if callback then
			callback()
		end
	end
end
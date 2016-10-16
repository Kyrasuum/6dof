//===== Copyright © 1996-2005, Valve Corporation, All rights reserved. ======//
//
// Purpose:
//
//===========================================================================//

function RemapValClamped( val, A, B, C, D)
	if ( A == B ) then
		if ( val >= B ) then
			return D;
		else
			return C;
		end
	end
	local cVal = (val - A) / (B - A);
	cVal = math.Clamp( cVal, 0.0, 1.0 );

	return C + (D - C) * cVal;
end

function AngleNegate(a)
	a.pitch = -a.pitch;
	a.yaw   = -a.yaw;
	a.roll  = -a.roll;

	return a
end

function VectorNegate(a)
	a.x = -a.x;
	a.y = -a.y;
	a.z = -a.z;

	return a
end


function VectorMAInline( start, scale, direction, dest )
	dest = dest || vec3_origin
	dest.x=start.x+direction.x*scale;
	dest.y=start.y+direction.y*scale;
	dest.z=start.z+direction.z*scale;

	return dest
end

function VectorMA( start, scale, direction, dest )
	return VectorMAInline(start, scale, direction, dest);
end



// MATH_BASE_H


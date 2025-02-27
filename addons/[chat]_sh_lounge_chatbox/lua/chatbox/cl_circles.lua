
local _R = debug.getregistry()

if ( _R.Circles ) then return _R.Circles end

local BlurMat = Material( "pp/blurscreen" )

local CIRCLE = {}
CIRCLE.__index = CIRCLE

do

  CIRCLE_FILLED = 0
  CIRCLE_OUTLINED = 1
  CIRCLE_BLURRED = 2

end

local err = "bad argument #%i to '%s' ( %s expected, got %s )"
local function assert( cond, arg, name, expected, got )

  if ( !cond ) then

    error( string.format( err, arg, name, expected, type( got ) ), 3 )

  end

end

local function New( typ, x, y, radius, ... )

  assert( isnumber( typ ), 1, "New", "number", typ )
  assert( isnumber( x ), 2, "New", "number", x )
  assert( isnumber( y ), 3, "New", "number", y )
  assert( isnumber( radius ), 4, "New", "number", radius )

  local circle = setmetatable( {}, CIRCLE )

  circle:SetType( tonumber( typ ) )
  circle:SetRadius( tonumber( radius ) )
  circle:SetPos( tonumber( x ), tonumber( y ) )

  if ( typ == CIRCLE_OUTLINED ) then

    local outline_width = ( { ... } )[ 1 ]
    circle:SetOutlineWidth( tonumber( outline_width ) )

  elseif ( typ == CIRCLE_BLURRED ) then

    local blur_layers, blur_density = unpack( { ... } )
    circle:SetBlurLayers( tonumber( blur_layers ) )
    circle:SetBlurDensity( tonumber( blur_density ) )

  end

  return circle
end

local function RotateVertices( vertices, ox, oy, rotation, rotate_uv )

  assert( isnumber( vertices ), 1, "RotateVertices", "table", vertices )
  assert( isnumber( ox ), 2, "RotateVertices", "number", ox )
  assert( isnumber( oy ), 3, "RotateVertices", "number", oy )
  assert( isnumber( rotation ), 4, "RotateVertices", "number", rotation )

  rotation = math.rad( rotation )

  local c = math.cos( rotation )
  local s = math.sin( rotation )

  for i = 1, #vertices do

    local vertex = vertices[ i ]
    local vx, vy = vertex.x, vertex.y

    vx = vx - ox
    vy = vy - oy

    vertex.x = ox + ( vx * c - vy * s )
    vertex.y = oy + ( vy * s + vy * c )

    if ( !rotate_uv ) then

      local u, v = vertex.u, vertex.v

      u, v = u - .5, v - .5

      vertex.u = .5 + ( u * c - v * s )
      vertex.v = .5 + ( u * s + v * c )

    end

  end

end

local function CalculateVertices( x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv )

  assert( isnumber( x ), 1, "CalculateVertices", "number", x )
  assert( isnumber( y ), 2, "CalculateVertices", "number", y )
  assert( isnumber( radius ), 3, "CalculateVertices", "number", radius )
  assert( isnumber( rotation ), 4, "CalculateVertices", "number", rotation )
  assert( isnumber( start_angle ), 5, "CalculateVertices", "number", start_angle )
  assert( isnumber( end_angle ), 6, "CalculateVertices", "number", end_angle )
  assert( isnumber( distance ), 7, "CalculateVertices", "number", distance )

  local vertices = {}
  local step = ( distance * 360 ) / ( 2 * math.pi * radius )

  for a = start_angle, end_angle + step, step do

    a = math.min( end_angle, a )
    a = math.rad( a )

    local c = math.cos( a )
    local s = math.sin( a )

    local vertex = {

      x = x + c * radius,
      y = y + s * radius,

      u = .5 + c / 2,
      v = .5 + s / 2

    }

    table.insert( vertices, vertex )

  end

  if ( end_angle - start_angle != 360 ) then

    table.insert( vertices, 1, {

      x = x,
      y = y,
      u = .5,
      v = .5

    } )

  else

    table.remove( vertices )

  end

  if ( rotation != 0 ) then

    RotateVertices( vertices, x, y, rotation, rotate_uv )

  end

  return vertices

end

function CIRCLE:__tostring()

  return string.format( "Circle: %p", self )

end

function CIRCLE:Copy()

  return table.Copy( self )

end

function CIRCLE:Calculate()

  local rotate_uv = self:GetRotateMaterial()
  local x, y = self:GetPos()
  local radius = self:GetRadius()
  local rotation = self:GetRotation()
  local start_angle = self:GetStartAngle()
  local end_angle = self:GetEndAngle()
  local distance = self:GetDistance()

  if ( radius <= 0 ) then

    error( string.format( "Circle radius should be higher than 0. ( %.2f )", radius ), 3 )

  elseif ( end_angle - start_angle <= 0 ) then

    error( string.format( "Circle angles should be higher than 0. ( %.2f )", end_angle - start_angle ), 3 )

  elseif ( distance <= 0 ) then

    error( string.format( "Circle vertice distance should be higher than 0. ( %2.f )", distance ), 3 )

  end

  self:SetVertices( CalculateVertices( x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv ) )

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    local inner = self:GetChildCircle() || self:Copy()

    inner:SetType( CIRCLE_FILLED )
    inner:SetRadius( self:GetRadius() - self:GetOutlineWidth() )
    inner:SetAcceptRadians( false )
    inner:SetAngles( 0, 360 )

    inner:SetColor( false )
    inner:SetMaterial( false )
    inner:SetDisableClipping( false )

    self:SetChildCircle( inner )

  end

  self:SetDirty( false )

end

function CIRCLE:__call()

  if ( self:GetDirty() ) then

    self:Calculate()

  end

  if ( #self:GetVertices() < 3 ) then return end

  if ( IsColor( self:GetColor() ) ) then

    local col = self:GetColor()
    surface.SetDrawColor( col.r, col.g, col.b, col.a )

  end

  if ( TypeID( self:GetMaterial() ) == TYPE_MATERIAL ) then

    surface.SetMaterial( self:GetMaterial() )

  elseif ( self:GetMaterial() == true ) then

    draw.NoTexture()

  end

  local clip = self:GetDisableClipping()
  if ( clip ) then

    surface.DisableClipping( true )

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    render.ClearStencil()

    render.SetStencilEnable( true )

      render.SetStencilTestMask( 0xFF )
      render.SetStencilWriteMask( 0xFF )
      render.SetStencilReferenceValue( 0x01 )

      render.SetStencilCompareFunction( STENCIL_NEVER )
      render.SetStencilFailOperation( STENCIL_REPLACE )
      render.SetStencilZFailOperation( STENCIL_REPLACE )

      self:GetChildCircle()()

      render.SetStencilCompareFunction( STENCIL_GREATER )
      render.SetStencilFailOperation( STENCIL_KEEP )
      render.SetStencilZFailOperation( STENCIL_KEEP )

      surface.DrawPoly( self:GetVertices() )

    render.SetStencilEnable( false )

  elseif ( self:GetType() == CIRCLE_BLURRED ) then

    render.ClearStencil()

    render.SetStencilEnable( true )

      render.SetStencilTestMask( 0xFF )
      render.SetStencilWriteMask( 0xFF )
      render.SetStencilReferenceValue( 0x01 )

      render.SetStencilCompareFunction( STENCIL_NEVER )
      render.SetStencilFailOperation( STENCIL_REPLACE )
      render.SetStencilZFailOperation( STENCIL_REPLACE )

      surface.DrawPoly( self:GetVertices() )

      render.SetStencilCompareFunction( STENCIL_LESSEQUAL )
      render.SetStencilFailOperation( STENCIL_KEEP )
      render.SetStencilZFailOperation( STENCIL_KEEP )

      surface.SetMaterial( BlurMat )

      local sw, sh = ScrW(), ScrH()

      for i = 1, self:GetBlurLayers() do

        BlurMat:SetFloat( "$blur", ( i / self:GetBlurLayers() ) * self:GetBlurDensity() )
        BlurMat:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( 0, 0, sw, sh )

      end

    render.SetStencilEnable( false )

  else

    surface.DrawPoly( self:GetVertices() )

  end

  if ( clip ) then surface.DisableClipping( false ) end

end

function CIRCLE:Translate( x, y )

  x = tonumber( x )
  y = tonumber( y )

  if ( !( x && y ) ) then return end
  if ( x == 0 && y == 0 ) then return end

  self.m_X = self:GetX() + x
  self.m_Y = self:GetY() + y

  if ( self:GetDirty() ) then return end

  x = tonumber( x ) || 0
  y = tonumber( y ) || 0

  for _, v in ipairs( self:GetVertices() ) do

    v.x = v.x + x
    v.y = v.y + y

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Translate( x, y )

  end

end

function CIRCLE:Scale( scale )

  scale = tonumber( scale )

  if ( !scale || scale == 1 ) then return end

  self.m_Radius = self:GetRadius() * scale

  if ( self:GetDirty() ) then return end

  local x, y = self:GetPos()

  for _, vertex in ipairs( self:GetVertices() ) do

    vertex.x = x + ( ( vertex.x - x ) * scale )
    vertex.y = y + ( ( vertex.y - y ) * scale )

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Scale( scale )

  end

end

function CIRCLE:Rotate( rotation )

  rotation = tonumber( rotation )

  if ( !rotation || rotation == 0 ) then return end

  if ( self:GetAcceptRadians() ) then rotation = math.deg( rotation ) end

  self.m_Rotation = self:GetRotation() + rotation

  if ( self:GetDirty() ) then return end

  local x, y = self:GetPos()
  local vertices = self:GetVertices()
  local rotate_uv = self:GetRotateMaterial()

  RotateVertices( vertices, x, y, rotation, rotate_uv )

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Rotate( rotation )

  end

end

do

  local function AccessorFunc( name, default, dirty, callback )

    local varname = "m_" .. name

    CIRCLE[ "Get" .. name ] = function( self )

      return self[ varname ]

    end

    CIRCLE[ "Set" .. name ] = function( self, value )

      if ( default != nil && value == nil ) then value = default end

      if ( self[ varname ] != value ) then

        if ( dirty ) then

          self[ dirty ] = true

        end

        if ( isfunction( callback ) ) then

          value = callback( self, self[ varname ], value ) || value

        end

        self[ varname ] = value

      end

    end

    CIRCLE[ varname ] = default

  end

  local function OffsetVerticesX( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    for _, vertex in ipairs( circle:GetVertices() ) do

      vertex.x = vertex.x + ( new - old )

    end

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      OffsetVerticesX( circle:GetChildCircle(), old, new )

    end

  end

  local function OffsetVerticesY( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    for _, vertex in ipairs( circle:GetVertices() ) do

      vertex.y = vertex.y + ( new - old )

    end

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      OffsetVerticesY( circle:GetChildCircle(), old, new )

    end

  end

  local function UpdateRotation( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    if ( circle:GetAcceptRadians() ) then

      new = math.deg( new )

    end

    local vertices = circle:GetVertices()
    local x, y = circle:GetPos()
    local rotation = new - old
    local rotate_uv = circle:GetRotateMaterial()

    RotateVertices( vertices, x, y, rotation, rotate_uv )

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      UpdateRotation( circle:GetChildCircle(), old, new )

    end

  end

  local function UpdateStartAngle( circle, old, new )

    if ( circle:GetAcceptRadians() ) then

      return math.deg( new )

    end

  end

  local function UpdateEndAngle( circle, old, new )

    if ( circle:GetAcceptRadians() ) then

      return math.deg( new )

    end

  end

  AccessorFunc( "Dirty", true )
  AccessorFunc( "Vertices", true )
  AccessorFunc( "ChildCircle", false )

  AccessorFunc( "Color", false )
  AccessorFunc( "Material", false )
  AccessorFunc( "AcceptRadians", false )
  AccessorFunc( "RotateMaterial", true )
  AccessorFunc( "DisableClipping", false )

  AccessorFunc( "Type", CIRCLE_FILLED, "m_Dirty" )
  AccessorFunc( "X", 0, false, OffsetVerticesX )
  AccessorFunc( "Y", 0, false, OffsetVerticesY )
  AccessorFunc( "Radius", 8, "m_Dirty" )
  AccessorFunc( "Rotation", 0, false, UpdateRotation )
  AccessorFunc( "StartAngle", 0, "m_Dirty", UpdateStartAngle )
  AccessorFunc( "EndAngle", 360, "m_Dirty", UpdateEndAngle )
  AccessorFunc( "Distance", 10, "m_Dirty" )

  AccessorFunc( "BlurLayers", 3 )
  AccessorFunc( "BlurDensity", 2 )
  AccessorFunc( "OutlineWidth", 10, "m_Dirty" )

  function CIRCLE:SetPos( x, y )

    self:SetX( x )
    self:SetY( y )

  end

  function CIRCLE:SetAngles( s, e )

    self:SetStartAngle( s )
    self:SetEndAngle( e )

  end

  function CIRCLE:GetPos()

    return self:GetX(), self:GetY()

  end

  function CIRCLE:GetAngles()

    return self:GetStartAngle(), self:GetEndAngle()

  end

end

_R.Circles = {

  New = New,
  RotateVertices = RotateVertices,
  CalculateVertices = CalculateVertices

}

return _R.Circles

local _R = debug.getregistry()

if ( _R.Circles ) then return _R.Circles end

local BlurMat = Material( "pp/blurscreen" )

local CIRCLE = {}
CIRCLE.__index = CIRCLE

do

  CIRCLE_FILLED = 0
  CIRCLE_OUTLINED = 1
  CIRCLE_BLURRED = 2

end

local err = "bad argument #%i to '%s' ( %s expected, got %s )"
local function assert( cond, arg, name, expected, got )

  if ( !cond ) then

    error( string.format( err, arg, name, expected, type( got ) ), 3 )

  end

end

local function New( typ, x, y, radius, ... )

  assert( isnumber( typ ), 1, "New", "number", typ )
  assert( isnumber( x ), 2, "New", "number", x )
  assert( isnumber( y ), 3, "New", "number", y )
  assert( isnumber( radius ), 4, "New", "number", radius )

  local circle = setmetatable( {}, CIRCLE )

  circle:SetType( tonumber( typ ) )
  circle:SetRadius( tonumber( radius ) )
  circle:SetPos( tonumber( x ), tonumber( y ) )

  if ( typ == CIRCLE_OUTLINED ) then

    local outline_width = ( { ... } )[ 1 ]
    circle:SetOutlineWidth( tonumber( outline_width ) )

  elseif ( typ == CIRCLE_BLURRED ) then

    local blur_layers, blur_density = unpack( { ... } )
    circle:SetBlurLayers( tonumber( blur_layers ) )
    circle:SetBlurDensity( tonumber( blur_density ) )

  end

  return circle
end

local function RotateVertices( vertices, ox, oy, rotation, rotate_uv )

  assert( isnumber( vertices ), 1, "RotateVertices", "table", vertices )
  assert( isnumber( ox ), 2, "RotateVertices", "number", ox )
  assert( isnumber( oy ), 3, "RotateVertices", "number", oy )
  assert( isnumber( rotation ), 4, "RotateVertices", "number", rotation )

  rotation = math.rad( rotation )

  local c = math.cos( rotation )
  local s = math.sin( rotation )

  for i = 1, #vertices do

    local vertex = vertices[ i ]
    local vx, vy = vertex.x, vertex.y

    vx = vx - ox
    vy = vy - oy

    vertex.x = ox + ( vx * c - vy * s )
    vertex.y = oy + ( vy * s + vy * c )

    if ( !rotate_uv ) then

      local u, v = vertex.u, vertex.v

      u, v = u - .5, v - .5

      vertex.u = .5 + ( u * c - v * s )
      vertex.v = .5 + ( u * s + v * c )

    end

  end

end

local function CalculateVertices( x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv )

  assert( isnumber( x ), 1, "CalculateVertices", "number", x )
  assert( isnumber( y ), 2, "CalculateVertices", "number", y )
  assert( isnumber( radius ), 3, "CalculateVertices", "number", radius )
  assert( isnumber( rotation ), 4, "CalculateVertices", "number", rotation )
  assert( isnumber( start_angle ), 5, "CalculateVertices", "number", start_angle )
  assert( isnumber( end_angle ), 6, "CalculateVertices", "number", end_angle )
  assert( isnumber( distance ), 7, "CalculateVertices", "number", distance )

  local vertices = {}
  local step = ( distance * 360 ) / ( 2 * math.pi * radius )

  for a = start_angle, end_angle + step, step do

    a = math.min( end_angle, a )
    a = math.rad( a )

    local c = math.cos( a )
    local s = math.sin( a )

    local vertex = {

      x = x + c * radius,
      y = y + s * radius,

      u = .5 + c / 2,
      v = .5 + s / 2

    }

    table.insert( vertices, vertex )

  end

  if ( end_angle - start_angle != 360 ) then

    table.insert( vertices, 1, {

      x = x,
      y = y,
      u = .5,
      v = .5

    } )

  else

    table.remove( vertices )

  end

  if ( rotation != 0 ) then

    RotateVertices( vertices, x, y, rotation, rotate_uv )

  end

  return vertices

end

function CIRCLE:__tostring()

  return string.format( "Circle: %p", self )

end

function CIRCLE:Copy()

  return table.Copy( self )

end

function CIRCLE:Calculate()

  local rotate_uv = self:GetRotateMaterial()
  local x, y = self:GetPos()
  local radius = self:GetRadius()
  local rotation = self:GetRotation()
  local start_angle = self:GetStartAngle()
  local end_angle = self:GetEndAngle()
  local distance = self:GetDistance()

  if ( radius <= 0 ) then

    error( string.format( "Circle radius should be higher than 0. ( %.2f )", radius ), 3 )

  elseif ( end_angle - start_angle <= 0 ) then

    error( string.format( "Circle angles should be higher than 0. ( %.2f )", end_angle - start_angle ), 3 )

  elseif ( distance <= 0 ) then

    error( string.format( "Circle vertice distance should be higher than 0. ( %2.f )", distance ), 3 )

  end

  self:SetVertices( CalculateVertices( x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv ) )

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    local inner = self:GetChildCircle() || self:Copy()

    inner:SetType( CIRCLE_FILLED )
    inner:SetRadius( self:GetRadius() - self:GetOutlineWidth() )
    inner:SetAcceptRadians( false )
    inner:SetAngles( 0, 360 )

    inner:SetColor( false )
    inner:SetMaterial( false )
    inner:SetDisableClipping( false )

    self:SetChildCircle( inner )

  end

  self:SetDirty( false )

end

function CIRCLE:__call()

  if ( self:GetDirty() ) then

    self:Calculate()

  end

  if ( #self:GetVertices() < 3 ) then return end

  if ( IsColor( self:GetColor() ) ) then

    local col = self:GetColor()
    surface.SetDrawColor( col.r, col.g, col.b, col.a )

  end

  if ( TypeID( self:GetMaterial() ) == TYPE_MATERIAL ) then

    surface.SetMaterial( self:GetMaterial() )

  elseif ( self:GetMaterial() == true ) then

    draw.NoTexture()

  end

  local clip = self:GetDisableClipping()
  if ( clip ) then

    surface.DisableClipping( true )

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    render.ClearStencil()

    render.SetStencilEnable( true )

      render.SetStencilTestMask( 0xFF )
      render.SetStencilWriteMask( 0xFF )
      render.SetStencilReferenceValue( 0x01 )

      render.SetStencilCompareFunction( STENCIL_NEVER )
      render.SetStencilFailOperation( STENCIL_REPLACE )
      render.SetStencilZFailOperation( STENCIL_REPLACE )

      self:GetChildCircle()()

      render.SetStencilCompareFunction( STENCIL_GREATER )
      render.SetStencilFailOperation( STENCIL_KEEP )
      render.SetStencilZFailOperation( STENCIL_KEEP )

      surface.DrawPoly( self:GetVertices() )

    render.SetStencilEnable( false )

  elseif ( self:GetType() == CIRCLE_BLURRED ) then

    render.ClearStencil()

    render.SetStencilEnable( true )

      render.SetStencilTestMask( 0xFF )
      render.SetStencilWriteMask( 0xFF )
      render.SetStencilReferenceValue( 0x01 )

      render.SetStencilCompareFunction( STENCIL_NEVER )
      render.SetStencilFailOperation( STENCIL_REPLACE )
      render.SetStencilZFailOperation( STENCIL_REPLACE )

      surface.DrawPoly( self:GetVertices() )

      render.SetStencilCompareFunction( STENCIL_LESSEQUAL )
      render.SetStencilFailOperation( STENCIL_KEEP )
      render.SetStencilZFailOperation( STENCIL_KEEP )

      surface.SetMaterial( BlurMat )

      local sw, sh = ScrW(), ScrH()

      for i = 1, self:GetBlurLayers() do

        BlurMat:SetFloat( "$blur", ( i / self:GetBlurLayers() ) * self:GetBlurDensity() )
        BlurMat:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( 0, 0, sw, sh )

      end

    render.SetStencilEnable( false )

  else

    surface.DrawPoly( self:GetVertices() )

  end

  if ( clip ) then surface.DisableClipping( false ) end

end

function CIRCLE:Translate( x, y )

  x = tonumber( x )
  y = tonumber( y )

  if ( !( x && y ) ) then return end
  if ( x == 0 && y == 0 ) then return end

  self.m_X = self:GetX() + x
  self.m_Y = self:GetY() + y

  if ( self:GetDirty() ) then return end

  x = tonumber( x ) || 0
  y = tonumber( y ) || 0

  for _, v in ipairs( self:GetVertices() ) do

    v.x = v.x + x
    v.y = v.y + y

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Translate( x, y )

  end

end

function CIRCLE:Scale( scale )

  scale = tonumber( scale )

  if ( !scale || scale == 1 ) then return end

  self.m_Radius = self:GetRadius() * scale

  if ( self:GetDirty() ) then return end

  local x, y = self:GetPos()

  for _, vertex in ipairs( self:GetVertices() ) do

    vertex.x = x + ( ( vertex.x - x ) * scale )
    vertex.y = y + ( ( vertex.y - y ) * scale )

  end

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Scale( scale )

  end

end

function CIRCLE:Rotate( rotation )

  rotation = tonumber( rotation )

  if ( !rotation || rotation == 0 ) then return end

  if ( self:GetAcceptRadians() ) then rotation = math.deg( rotation ) end

  self.m_Rotation = self:GetRotation() + rotation

  if ( self:GetDirty() ) then return end

  local x, y = self:GetPos()
  local vertices = self:GetVertices()
  local rotate_uv = self:GetRotateMaterial()

  RotateVertices( vertices, x, y, rotation, rotate_uv )

  if ( self:GetType() == CIRCLE_OUTLINED ) then

    self:GetChildCircle():Rotate( rotation )

  end

end

do

  local function AccessorFunc( name, default, dirty, callback )

    local varname = "m_" .. name

    CIRCLE[ "Get" .. name ] = function( self )

      return self[ varname ]

    end

    CIRCLE[ "Set" .. name ] = function( self, value )

      if ( default != nil && value == nil ) then value = default end

      if ( self[ varname ] != value ) then

        if ( dirty ) then

          self[ dirty ] = true

        end

        if ( isfunction( callback ) ) then

          value = callback( self, self[ varname ], value ) || value

        end

        self[ varname ] = value

      end

    end

    CIRCLE[ varname ] = default

  end

  local function OffsetVerticesX( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    for _, vertex in ipairs( circle:GetVertices() ) do

      vertex.x = vertex.x + ( new - old )

    end

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      OffsetVerticesX( circle:GetChildCircle(), old, new )

    end

  end

  local function OffsetVerticesY( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    for _, vertex in ipairs( circle:GetVertices() ) do

      vertex.y = vertex.y + ( new - old )

    end

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      OffsetVerticesY( circle:GetChildCircle(), old, new )

    end

  end

  local function UpdateRotation( circle, old, new )

    if ( circle:GetDirty() || !circle:GetVertices() ) then return end

    if ( circle:GetAcceptRadians() ) then

      new = math.deg( new )

    end

    local vertices = circle:GetVertices()
    local x, y = circle:GetPos()
    local rotation = new - old
    local rotate_uv = circle:GetRotateMaterial()

    RotateVertices( vertices, x, y, rotation, rotate_uv )

    if ( circle:GetType() == CIRCLE_OUTLINED ) then

      UpdateRotation( circle:GetChildCircle(), old, new )

    end

  end

  local function UpdateStartAngle( circle, old, new )

    if ( circle:GetAcceptRadians() ) then

      return math.deg( new )

    end

  end

  local function UpdateEndAngle( circle, old, new )

    if ( circle:GetAcceptRadians() ) then

      return math.deg( new )

    end

  end

  AccessorFunc( "Dirty", true )
  AccessorFunc( "Vertices", true )
  AccessorFunc( "ChildCircle", false )

  AccessorFunc( "Color", false )
  AccessorFunc( "Material", false )
  AccessorFunc( "AcceptRadians", false )
  AccessorFunc( "RotateMaterial", true )
  AccessorFunc( "DisableClipping", false )

  AccessorFunc( "Type", CIRCLE_FILLED, "m_Dirty" )
  AccessorFunc( "X", 0, false, OffsetVerticesX )
  AccessorFunc( "Y", 0, false, OffsetVerticesY )
  AccessorFunc( "Radius", 8, "m_Dirty" )
  AccessorFunc( "Rotation", 0, false, UpdateRotation )
  AccessorFunc( "StartAngle", 0, "m_Dirty", UpdateStartAngle )
  AccessorFunc( "EndAngle", 360, "m_Dirty", UpdateEndAngle )
  AccessorFunc( "Distance", 10, "m_Dirty" )

  AccessorFunc( "BlurLayers", 3 )
  AccessorFunc( "BlurDensity", 2 )
  AccessorFunc( "OutlineWidth", 10, "m_Dirty" )

  function CIRCLE:SetPos( x, y )

    self:SetX( x )
    self:SetY( y )

  end

  function CIRCLE:SetAngles( s, e )

    self:SetStartAngle( s )
    self:SetEndAngle( e )

  end

  function CIRCLE:GetPos()

    return self:GetX(), self:GetY()

  end

  function CIRCLE:GetAngles()

    return self:GetStartAngle(), self:GetEndAngle()

  end

end

_R.Circles = {

  New = New,
  RotateVertices = RotateVertices,
  CalculateVertices = CalculateVertices

}

return _R.Circles

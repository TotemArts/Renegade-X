class Rx_DynamicNavMeshObstacle extends NavMeshObstacle;

// List of possible shapes
enum EShape
{
  EShape_None,
  EShape_Square,
  EShape_Rectangle,
  EShape_Circle
};

// Shape of the nav mesh obstacle
var PrivateWrite EShape ShapeType;
// Used in EShape_Square
var PrivateWrite float Width;
// Used in EShape_Square and EShape_Rectangle
var PrivateWrite float Height;
// Used in EShape_Circle
var PrivateWrite float Radius;
// Used in EShape_Circle
var PrivateWrite int Sides;
// Align the obstacle to the rotation of the actor?
var bool AlignToRotation;

simulated function PostBeginPlay()
{
  // Skip default post begin play function
  Super(Actor).PostBeginPlay();
}

function SetAsSquare(float NewWidth)
{
  if (NewWidth > 0.f)
  {
    ShapeType = EShape_Square;
    Width = NewWidth;
  }
}

function SetAsRectangle(float NewWidth, float NewHeight)
{
  if (NewWidth > 0.f && NewHeight > 0.f)
  {
    ShapeType = EShape_Rectangle;
    Width = NewWidth;
    Height = NewHeight;
  }
}

function SetAsCircle(float NewRadius, float NewSides)
{
  if (NewRadius > 0.f && NewSides > 0)
  {
    ShapeType = EShape_Circle;
    Radius = NewRadius;
    Sides = NewSides;
  }
}

event bool GetObstacleBoudingShape(out array<vector> Shape)
{
  local Vector Offset;
  local int i, Angle;
  local Rotator R;

  if (ShapeType == EShape_Square)
  {
    if (AlignToRotation)
    {
      // Top right corner
      Offset.X = Width;
      Offset.Y = Width;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Bottom right corner
      Offset.X = -Width;
      Offset.Y = Width;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Bottom left corner
      Offset.X = -Width;
      Offset.Y = -Width;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Top left corner
      Offset.X = Width;
      Offset.Y = -Width;
      Shape.AddItem(Location + (Offset >> Rotation));
    }
    else
    {
      // Top right corner
      Offset.X = Width;
      Offset.Y = Width;
      Shape.AddItem(Location + Offset);
      // Bottom right corner
      Offset.X = -Width;
      Offset.Y = Width;
      Shape.AddItem(Location + Offset);
      // Bottom left corner
      Offset.X = -Width;
      Offset.Y = -Width;
      Shape.AddItem(Location + Offset);
      // Top left corner
      Offset.X = Width;
      Offset.Y = -Width;
      Shape.AddItem(Location + Offset);
    }

    return true;
  }
  else if (ShapeType == EShape_Rectangle)
  {
    if (AlignToRotation)
    {
      // Top right corner
      Offset.X = Width;
      Offset.Y = Height;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Bottom right corner
      Offset.X = -Width;
      Offset.Y = Height;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Bottom left corner
      Offset.X = -Width;
      Offset.Y = -Height;
      Shape.AddItem(Location + (Offset >> Rotation));
      // Top left corner
      Offset.X = Width;
      Offset.Y = -Height;
      Shape.AddItem(Location + (Offset >> Rotation));
    }
    else
    {
      // Top right corner
      Offset.X = Width;
      Offset.Y = Height;
      Shape.AddItem(Location + Offset);
      // Bottom right corner
      Offset.X = -Width;
      Offset.Y = Height;
      Shape.AddItem(Location + Offset);
      // Bottom left corner
      Offset.X = -Width;
      Offset.Y = -Height;
      Shape.AddItem(Location + Offset);
      // Top left corner
      Offset.X = Width;
      Offset.Y = -Height;
      Shape.AddItem(Location + Offset);
    }

    return true;
  }
  else if (ShapeType == EShape_Circle && Sides > 0)
  {
    // Get the angle of each 'slice' defined by the number of sides
    Angle = 65536 / Sides;
    // If we are aligned to rotation, use the rotation as the starting point
    R = (AlignToRotation) ? Rotation : Rot(0, 0, 0);
    // Set the radius
    Offset.X = Radius;
    Offset.Y = 0.f;
    // For each side...
    for (i = 0; i < Sides; ++i)
    {
      // Add the the left side point
      Shape.AddItem(Location + (Offset >> R));
      // Increment to the next side
      R.Yaw += Angle;
    }

    return true;
  }

  return false;
}

defaultproperties
{
}
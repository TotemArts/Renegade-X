  class SeqAct_TogglePostProcessEffect extends SeqAct_SetPostProcessEffectProperties;
  
  var bool Value;
  
  event Activated()
  {
    local array<PostProcessEffect> PostProcessEffects;
    local int i;
  
    if (InputLinks[0].bHasImpulse) // Enable
    {
      Value = true;
    }
    else if (InputLinks[1].bHasImpulse) // Disable
    {
      Value = false;
    }
    else if (InputLinks[2].bHasImpulse) // Toggle
    {
      Value = !Value;
    }
  
    GetPostProcessEffects(PostProcessEffects);
  
    if (PostProcessEffects.Length > 0)
    {
      for (i = 0; i < PostProcessEffects.length; ++i)
      {
        if (PostProcessEffects[i] != None)
        {
          PostProcessEffects[i].bShowInEditor = Value;
          PostProcessEffects[i].bShowInGame = Value;
        }
      }
    }
  }
  
  defaultproperties
  {
    ObjName="Toggle Post Process Effects"
    ObjCategory="Post Process"
  
    InputLinks(0)=(LinkDesc="Enable")
    InputLinks(1)=(LinkDesc="Disable")
    InputLinks(2)=(LinkDesc="Toggle")
  
    VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",bWriteable=true,MinVars=0,PropertyName=Value)
  }
  
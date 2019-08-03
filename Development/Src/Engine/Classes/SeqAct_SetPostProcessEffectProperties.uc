  class SeqAct_SetPostProcessEffectProperties extends SequenceAction
    abstract;
  
  var() Name PostProcessEffectName;
  
  function GetPostProcessEffects(out array<PostProcessEffect> PostProcessEffects, optional class<PostProcessEffect> MatchingPostProcessEffectClass = class'PostProcessEffect')
  {
    local WorldInfo WorldInfo;
    local PostProcessEffect PostProcessEffect;
    local PlayerController PlayerController;
    local LocalPlayer LocalPlayer;
  
    WorldInfo = class'WorldInfo'.static.GetWorldInfo();
  
    // Affect the world post process chain
    if (WorldInfo != None)
    {
      ForEach WorldInfo.AllControllers(class'PlayerController', PlayerController)
      {
        LocalPlayer = LocalPlayer(PlayerController.Player);
  
        if (LocalPlayer != None && LocalPlayer.PlayerPostProcess != None)
        {
          PostProcessEffect = LocalPlayer.PlayerPostProcess.FindPostProcessEffect(PostProcessEffectName);
  
          if (PostProcessEffect != None && (PostProcessEffect.Class == MatchingPostProcessEffectClass || ClassIsChildOf(PostProcessEffect.Class, MatchingPostProcessEffectClass)))
          {
            PostProcessEffects.AddItem(PostProcessEffect);
          }
        }
      }
    }
  }
  
  defaultproperties
  {
  }
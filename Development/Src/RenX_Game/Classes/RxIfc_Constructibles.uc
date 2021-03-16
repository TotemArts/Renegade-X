interface RxIfc_Constructibles;

static function Vector GetBuildOffset();

static function Vector GetBuildRotationMultiplier();

static function float GetBuildScale();

static function float GetBuildClearRadius();

static function float GetBuildMinNormalZ();

static function float GetBuildMaxNormalZ();

static function ParticleSystem GetDeploymentEffect();

static function int GetBuildMeshType(); //0 for StaticMesh, 1 for SkeletalMesh

static function StaticMesh GetBuildModelSM();

static function SkeletalMesh GetBuildModelSK();

static function int GetBuildPrice();

static function float GetBuildRange();
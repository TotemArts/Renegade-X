interface Rx_IPurchasable;

enum EAvailability {
	PURCHASE_AVAILABLE,
	PURCHASE_NOTAVAILABLE,
	PURCHASE_HIDDEN
};

// Purchasing
static function Purchase(Rx_PRI Context);
static function int Cost(Rx_PRI Context);
static function EAvailability Available(Rx_PRI Context);

// Block Data
static function string Title();
static function string Description();
static function Texture Icon();

// Metadata
static function int StatType();
static function int DamageOutOfSix();
static function int RangeOutOfSix();
static function int RateOfFireOutOfSix();
static function int MagazineCapacityOutOfSize();

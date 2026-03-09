/// CosDNA-style ingredient database.
/// Keys are lowercase ingredient names for case-insensitive look-up.
///
/// Fields:
///   function   – ingredient role(s)
///   acneRisk   – 0 (none) → 5 (high);  null = not rated
///   irritant   – 0 (none) → 5 (high);  null = not rated
///   safety     – 1 (low concern) → 5 (high concern), EWG-inspired

class IngredientInfo {
  final String function;
  final int? acneRisk;
  final int? irritant;
  final int safety;

  const IngredientInfo({
    required this.function,
    this.acneRisk,
    this.irritant,
    required this.safety,
  });
}

const Map<String, IngredientInfo> ingredientDatabase = {
  // ── Water / Solvents ────────────────────────────────────────────────────
  'water': IngredientInfo(function: 'Solvent', acneRisk: 0, irritant: 0, safety: 1),
  'aqua': IngredientInfo(function: 'Solvent', acneRisk: 0, irritant: 0, safety: 1),

  // ── Humectants / Moisturisers ────────────────────────────────────────────
  'glycerin': IngredientInfo(function: 'Moisturizer, Humectant', acneRisk: 0, irritant: 0, safety: 1),
  'glycerol': IngredientInfo(function: 'Moisturizer, Humectant', acneRisk: 0, irritant: 0, safety: 1),
  'sodium hyaluronate': IngredientInfo(function: 'Moisturizer, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'hyaluronic acid': IngredientInfo(function: 'Moisturizer, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'panthenol': IngredientInfo(function: 'Moisturizer, Anti-inflammatory, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'propylene glycol': IngredientInfo(function: 'Moisturizer, Solvent', acneRisk: 0, irritant: 1, safety: 2),
  'butylene glycol': IngredientInfo(function: 'Moisturizer, Solvent', acneRisk: 0, irritant: 0, safety: 1),
  'pentylene glycol': IngredientInfo(function: 'Moisturizer, Preservative', acneRisk: 0, irritant: 0, safety: 1),
  'sorbitol': IngredientInfo(function: 'Moisturizer, Humectant', acneRisk: 0, irritant: 0, safety: 1),
  'urea': IngredientInfo(function: 'Moisturizer, Keratolytic', acneRisk: 0, irritant: 1, safety: 1),
  'lactic acid': IngredientInfo(function: 'Exfoliant, pH adjuster, Moisturizer', acneRisk: 0, irritant: 2, safety: 2),
  'glycolic acid': IngredientInfo(function: 'Exfoliant, Skin conditioning', acneRisk: 0, irritant: 3, safety: 2),
  'allantoin': IngredientInfo(function: 'Soothing, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'aloe vera': IngredientInfo(function: 'Soothing, Moisturizer, Anti-inflammatory', acneRisk: 0, irritant: 0, safety: 1),
  'aloe barbadensis leaf juice': IngredientInfo(function: 'Soothing, Moisturizer', acneRisk: 0, irritant: 0, safety: 1),

  // ── Emollients / Occlusives ──────────────────────────────────────────────
  'dimethicone': IngredientInfo(function: 'Emollient, Skin protectant', acneRisk: 1, irritant: 0, safety: 1),
  'cyclopentasiloxane': IngredientInfo(function: 'Emollient, Solvent', acneRisk: 0, irritant: 0, safety: 2),
  'cyclohexasiloxane': IngredientInfo(function: 'Emollient, Solvent', acneRisk: 0, irritant: 0, safety: 2),
  'squalane': IngredientInfo(function: 'Emollient, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'squalene': IngredientInfo(function: 'Emollient, Antioxidant', acneRisk: 2, irritant: 0, safety: 1),
  'jojoba seed oil': IngredientInfo(function: 'Emollient, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'coconut oil': IngredientInfo(function: 'Emollient, Skin conditioning', acneRisk: 4, irritant: 0, safety: 1),
  'shea butter': IngredientInfo(function: 'Emollient, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'petrolatum': IngredientInfo(function: 'Occlusive, Skin protectant', acneRisk: 0, irritant: 0, safety: 1),
  'mineral oil': IngredientInfo(function: 'Occlusive, Emollient', acneRisk: 0, irritant: 0, safety: 1),
  'niacinamide': IngredientInfo(function: 'Skin conditioning, Brightening, Pore-minimizing', acneRisk: 0, irritant: 0, safety: 1),
  'caprylyl glycol': IngredientInfo(function: 'Moisturizer, Emollient', acneRisk: 0, irritant: 0, safety: 1),

  // ── Ceramides / Barrier ──────────────────────────────────────────────────
  'ceramide np': IngredientInfo(function: 'Barrier repair, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'ceramide ap': IngredientInfo(function: 'Barrier repair, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'ceramide eop': IngredientInfo(function: 'Barrier repair, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'ceramide ng': IngredientInfo(function: 'Barrier repair, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'ceramide as': IngredientInfo(function: 'Barrier repair, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'cholesterol': IngredientInfo(function: 'Barrier repair, Emollient', acneRisk: 0, irritant: 0, safety: 1),
  'phytosphingosine': IngredientInfo(function: 'Barrier repair, Antimicrobial', acneRisk: 0, irritant: 0, safety: 1),

  // ── Emulsifiers / Surfactants ────────────────────────────────────────────
  'sodium lauroyl lactylate': IngredientInfo(function: 'Emulsifier, Surfactant', acneRisk: 0, irritant: 0, safety: 1),
  'cetearyl alcohol': IngredientInfo(function: 'Emollient, Emulsifier, Viscosity control', acneRisk: 2, irritant: 0, safety: 1),
  'cetyl alcohol': IngredientInfo(function: 'Emollient, Emulsifier', acneRisk: 2, irritant: 0, safety: 1),
  'stearic acid': IngredientInfo(function: 'Emulsifier, Skin conditioning', acneRisk: 3, irritant: 0, safety: 1),
  'polysorbate 20': IngredientInfo(function: 'Emulsifier, Surfactant', acneRisk: 0, irritant: 0, safety: 1),
  'polysorbate 80': IngredientInfo(function: 'Emulsifier, Surfactant', acneRisk: 0, irritant: 1, safety: 1),
  'peg-40 hydrogenated castor oil': IngredientInfo(function: 'Emulsifier, Surfactant', acneRisk: 0, irritant: 0, safety: 2),
  'sodium lauryl sulfate': IngredientInfo(function: 'Surfactant, Cleansing', acneRisk: 0, irritant: 5, safety: 3),
  'sodium laureth sulfate': IngredientInfo(function: 'Surfactant, Cleansing', acneRisk: 0, irritant: 3, safety: 2),
  'cocamidopropyl betaine': IngredientInfo(function: 'Surfactant, Cleansing', acneRisk: 0, irritant: 1, safety: 1),

  // ── Thickeners / Polymers ────────────────────────────────────────────────
  'carbomer': IngredientInfo(function: 'Viscosity control, Gel-forming', acneRisk: 0, irritant: 1, safety: 1),
  'xanthan gum': IngredientInfo(function: 'Viscosity control, Stabilizer', acneRisk: 0, irritant: 0, safety: 1),
  'hydroxyethylcellulose': IngredientInfo(function: 'Viscosity control, Film-forming', acneRisk: 0, irritant: 0, safety: 1),
  'hydroxypropyl methylcellulose': IngredientInfo(function: 'Viscosity control, Film-forming', acneRisk: 0, irritant: 0, safety: 1),
  'acrylates/c10-30 alkyl acrylate crosspolymer': IngredientInfo(function: 'Viscosity control', acneRisk: 0, irritant: 0, safety: 1),

  // ── pH adjusters ─────────────────────────────────────────────────────────
  'sodium hydroxide': IngredientInfo(function: 'pH adjuster', acneRisk: 0, irritant: 1, safety: 2),
  'citric acid': IngredientInfo(function: 'pH adjuster, Antioxidant', acneRisk: 0, irritant: 1, safety: 1),
  'triethanolamine': IngredientInfo(function: 'pH adjuster, Surfactant', acneRisk: 0, irritant: 1, safety: 2),

  // ── Chelating agents ─────────────────────────────────────────────────────
  'disodium edta': IngredientInfo(function: 'Chelating, Viscosity control', acneRisk: 0, irritant: 0, safety: 2),
  'edta': IngredientInfo(function: 'Chelating', acneRisk: 0, irritant: 0, safety: 2),
  'tetrasodium edta': IngredientInfo(function: 'Chelating', acneRisk: 0, irritant: 0, safety: 2),

  // ── Preservatives ────────────────────────────────────────────────────────
  'phenoxyethanol': IngredientInfo(function: 'Preservative', acneRisk: 0, irritant: 1, safety: 2),
  'ethylhexylglycerin': IngredientInfo(function: 'Preservative, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'benzyl alcohol': IngredientInfo(function: 'Preservative, Solvent', acneRisk: 0, irritant: 2, safety: 2),
  'methylparaben': IngredientInfo(function: 'Preservative', acneRisk: 0, irritant: 0, safety: 3),
  'propylparaben': IngredientInfo(function: 'Preservative', acneRisk: 0, irritant: 0, safety: 3),
  'chlorphenesin': IngredientInfo(function: 'Preservative', acneRisk: 0, irritant: 1, safety: 2),

  // ── Antioxidants ─────────────────────────────────────────────────────────
  'tocopherol': IngredientInfo(function: 'Antioxidant, Skin conditioning', acneRisk: 2, irritant: 0, safety: 1),
  'tocopheryl acetate': IngredientInfo(function: 'Antioxidant, Skin conditioning', acneRisk: 2, irritant: 0, safety: 1),
  'ascorbic acid': IngredientInfo(function: 'Antioxidant, Brightening', acneRisk: 0, irritant: 2, safety: 1),
  'ascorbyl glucoside': IngredientInfo(function: 'Antioxidant, Brightening', acneRisk: 0, irritant: 0, safety: 1),
  'ethyl ascorbic acid': IngredientInfo(function: 'Antioxidant, Brightening', acneRisk: 0, irritant: 0, safety: 1),
  '3-o-ethyl ascorbic acid': IngredientInfo(function: 'Antioxidant, Brightening', acneRisk: 0, irritant: 0, safety: 1),
  'vitamin c': IngredientInfo(function: 'Antioxidant, Brightening', acneRisk: 0, irritant: 2, safety: 1),
  'retinol': IngredientInfo(function: 'Anti-aging, Skin renewal', acneRisk: 0, irritant: 3, safety: 2),
  'retinyl palmitate': IngredientInfo(function: 'Anti-aging, Skin conditioning', acneRisk: 0, irritant: 1, safety: 3),
  'ferulic acid': IngredientInfo(function: 'Antioxidant, UV protection', acneRisk: 0, irritant: 0, safety: 1),
  'resveratrol': IngredientInfo(function: 'Antioxidant, Anti-aging', acneRisk: 0, irritant: 0, safety: 1),
  'madecassoside': IngredientInfo(function: 'Skin conditioning, Antioxidant, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'centella asiatica extract': IngredientInfo(function: 'Soothing, Anti-inflammatory, Plant extract', acneRisk: 0, irritant: 0, safety: 1),

  // ── Active ingredients ───────────────────────────────────────────────────
  'salicylic acid': IngredientInfo(function: 'Exfoliant, Acne treatment, Keratolytic', acneRisk: 0, irritant: 2, safety: 2),
  'benzoyl peroxide': IngredientInfo(function: 'Acne treatment, Antimicrobial', acneRisk: 0, irritant: 4, safety: 3),
  'azelaic acid': IngredientInfo(function: 'Brightening, Acne treatment, Anti-inflammatory', acneRisk: 0, irritant: 1, safety: 1),
  'tranexamic acid': IngredientInfo(function: 'Brightening, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'kojic acid': IngredientInfo(function: 'Brightening, Antioxidant', acneRisk: 0, irritant: 1, safety: 2),
  'arbutin': IngredientInfo(function: 'Brightening, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'alpha-arbutin': IngredientInfo(function: 'Brightening, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'zinc oxide': IngredientInfo(function: 'UV filter, Skin protectant', acneRisk: 0, irritant: 0, safety: 1),
  'titanium dioxide': IngredientInfo(function: 'UV filter, Opacifying', acneRisk: 0, irritant: 0, safety: 1),
  'adenosine': IngredientInfo(function: 'Anti-aging, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'peptide': IngredientInfo(function: 'Anti-aging, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'acetyl hexapeptide-3': IngredientInfo(function: 'Anti-aging, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'palmitoyl pentapeptide-4': IngredientInfo(function: 'Anti-aging, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),

  // ── Sunscreen actives ────────────────────────────────────────────────────
  'octinoxate': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 1, safety: 3),
  'oxybenzone': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 1, safety: 4),
  'avobenzone': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 1, safety: 2),
  'octocrylene': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 1, safety: 2),
  'tinosorb s': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 0, safety: 1),
  'uvinul a plus': IngredientInfo(function: 'UV filter', acneRisk: 0, irritant: 0, safety: 1),

  // ── Plant extracts ───────────────────────────────────────────────────────
  'green tea extract': IngredientInfo(function: 'Antioxidant, Anti-inflammatory, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'camellia sinensis leaf extract': IngredientInfo(function: 'Antioxidant, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'witch hazel extract': IngredientInfo(function: 'Astringent, Antioxidant, Plant extract', acneRisk: 0, irritant: 2, safety: 1),
  'chamomile extract': IngredientInfo(function: 'Soothing, Anti-inflammatory, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'licorice root extract': IngredientInfo(function: 'Brightening, Antioxidant, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'glycyrrhiza glabra root extract': IngredientInfo(function: 'Brightening, Soothing, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'portulaca oleracea extract': IngredientInfo(function: 'Soothing, Antioxidant, Plant extract', acneRisk: 0, irritant: 0, safety: 1),
  'ophiopogon japonicus root extract': IngredientInfo(function: 'Skin conditioning, Plant extract', acneRisk: 0, irritant: 0, safety: 1),

  // ── Miscellaneous ────────────────────────────────────────────────────────
  'maltodextrin': IngredientInfo(function: 'Skin conditioning, Film-forming', acneRisk: 0, irritant: 0, safety: 1),
  'niacinamide (vitamin b3)': IngredientInfo(function: 'Brightening, Pore-minimizing, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'caffeine': IngredientInfo(function: 'Antioxidant, Anti-inflammatory, Depuffing', acneRisk: 0, irritant: 0, safety: 1),
  'collagen': IngredientInfo(function: 'Moisturizer, Film-forming', acneRisk: 0, irritant: 0, safety: 1),
  'elastin': IngredientInfo(function: 'Moisturizer, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'biotin': IngredientInfo(function: 'Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'zinc pca': IngredientInfo(function: 'Sebum control, Skin conditioning', acneRisk: 0, irritant: 0, safety: 1),
  'sulfur': IngredientInfo(function: 'Acne treatment, Keratolytic', acneRisk: 0, irritant: 2, safety: 2),
  'tea tree oil': IngredientInfo(function: 'Antimicrobial, Acne treatment', acneRisk: 0, irritant: 3, safety: 2),
  'fragrance': IngredientInfo(function: 'Fragrance', acneRisk: 0, irritant: 4, safety: 3),
  'parfum': IngredientInfo(function: 'Fragrance', acneRisk: 0, irritant: 4, safety: 3),
  'alcohol denat.': IngredientInfo(function: 'Solvent, Astringent', acneRisk: 0, irritant: 3, safety: 2),
  'alcohol': IngredientInfo(function: 'Solvent, Astringent', acneRisk: 0, irritant: 3, safety: 2),
  'isopropyl myristate': IngredientInfo(function: 'Emollient, Solvent', acneRisk: 5, irritant: 1, safety: 2),
  'isopropyl palmitate': IngredientInfo(function: 'Emollient, Skin conditioning', acneRisk: 4, irritant: 0, safety: 1),
  'myristyl myristate': IngredientInfo(function: 'Emollient', acneRisk: 5, irritant: 0, safety: 1),
  'lanolin': IngredientInfo(function: 'Emollient, Occlusive', acneRisk: 1, irritant: 1, safety: 2),
  'silica': IngredientInfo(function: 'Absorbent, Mattifying', acneRisk: 0, irritant: 0, safety: 1),
  'mica': IngredientInfo(function: 'Opacifying, Colorant', acneRisk: 0, irritant: 0, safety: 1),
};

/// Look up an ingredient case-insensitively. Returns null if not in the DB.
IngredientInfo? lookupIngredient(String name) {
  return ingredientDatabase[name.toLowerCase().trim()];
}

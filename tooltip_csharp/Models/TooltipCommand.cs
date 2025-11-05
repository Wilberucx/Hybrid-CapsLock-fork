using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace TooltipApp.Models
{
    public class TooltipCommand
    {
        // Backward-compatible type overrides (legacy presets)
        [JsonPropertyName("tooltip_type")]
        public string TooltipType { get; set; } = "leader"; // leader | status_persistent | sidebar_right | bottom_right_list

        // Title and content
        [JsonPropertyName("title")]
        public string Title { get; set; } = "";

        [JsonPropertyName("items")]
        public List<TooltipItem> Items { get; set; } = new();

        [JsonPropertyName("navigation")]
        public List<string> Navigation { get; set; } = new();

        // Behavior
        [JsonPropertyName("timeout_ms")]
        public int TimeoutMs { get; set; } = 7000;

        [JsonPropertyName("show")]
        public bool Show { get; set; } = false;

        // New: layout and customization
        // layout: "grid" | "list"
        [JsonPropertyName("layout")]
        public string Layout { get; set; } = "grid";

        // columns applies when layout = grid
        [JsonPropertyName("columns")]
        public int Columns { get; set; } = 4;

        [JsonPropertyName("style")]
        public TooltipStyle Style { get; set; } = new();

        [JsonPropertyName("position")]
        public TooltipPosition Position { get; set; } = new();

        // Window flags
        [JsonPropertyName("topmost")]
        public bool? Topmost { get; set; }

        [JsonPropertyName("click_through")]
        public bool? ClickThrough { get; set; }

        [JsonPropertyName("opacity")]
        public double? Opacity { get; set; }
    }

    public class TooltipItem
    {
        [JsonPropertyName("key")]
        public string Key { get; set; } = "";

        [JsonPropertyName("description")]
        public string Description { get; set; } = "";

        // Optional per-item color (hex). If present, renderer will use it for key (and possibly description)
        [JsonPropertyName("color")]
        public string? Color { get; set; }
    }

    public class TooltipStyle
    {
        // Colors
        [JsonPropertyName("background")] public string? Background { get; set; }
        [JsonPropertyName("text")] public string? Text { get; set; }
        [JsonPropertyName("border")] public string? Border { get; set; }
        [JsonPropertyName("accent_options")] public string? AccentOptions { get; set; }
        [JsonPropertyName("accent_navigation")] public string? AccentNavigation { get; set; }
        [JsonPropertyName("navigation_text")] public string? NavigationText { get; set; }

        // Dimensions
        [JsonPropertyName("border_thickness")] public double? BorderThickness { get; set; }
        [JsonPropertyName("corner_radius")] public double? CornerRadius { get; set; }
        [JsonPropertyName("padding")] public double[]? Padding { get; set; } // [left, top, right, bottom]

        // Typography
        [JsonPropertyName("title_font_size")] public double? TitleFontSize { get; set; }
        [JsonPropertyName("item_font_size")] public double? ItemFontSize { get; set; }
        [JsonPropertyName("navigation_font_size")] public double? NavigationFontSize { get; set; }

        // Max width/height (optional)
        [JsonPropertyName("max_width")] public double? MaxWidth { get; set; }
        [JsonPropertyName("max_height")] public double? MaxHeight { get; set; }
    }

    public class TooltipPosition
    {
        // Anchor presets: bottom_center (default), bottom_right, bottom_left, top_center, top_left, top_right, center, manual
        [JsonPropertyName("anchor")] public string? Anchor { get; set; }

        // Offsets relative to anchor
        [JsonPropertyName("offset_x")] public double? OffsetX { get; set; }
        [JsonPropertyName("offset_y")] public double? OffsetY { get; set; }

        // Manual absolute position (when anchor = manual)
        [JsonPropertyName("x")] public double? X { get; set; }
        [JsonPropertyName("y")] public double? Y { get; set; }
    }
}

local BD = require("ui/bidi")
local Device = require("device")
local optionsutil = require("ui/data/optionsutil")
local _ = require("gettext")
local C_ = _.pgettext
local Screen = Device.screen

-- The values used for Font Size are not actually font sizes, but kopt zoom levels.
local FONT_SCALE_FACTORS = {0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.3, 1.6, 2.0}
-- Font sizes used for the font size widget only
local FONT_SCALE_DISPLAY_SIZE = {12, 14, 15, 16, 17, 18, 19, 20, 22, 25, 30, 35}

-- Get font scale numbers as a table of strings
local tableOfNumbersToTableOfStrings = function(numbers)
    local t = {}
    for i, v in ipairs(numbers) do
        table.insert(t, string.format("%0.1f", v))
    end
    return t
end

local KoptOptions = {
    prefix = 'kopt',
    needs_redraw_on_change = true,
    {
        icon = "resources/icons/appbar.transform.rotate.right.large.png",
        options = {
            {
                name = "rotation_mode",
                name_text = _("Rotation"),
                toggle = {C_("Rotation", "⤹ 90°"), C_("Rotation", "↑ 0°"), C_("Rotation", "⤸ 90°"), C_("Rotation", "↓ 180°")},
                alternate = false,
                values = {Screen.ORIENTATION_LANDSCAPE_ROTATED, Screen.ORIENTATION_PORTRAIT, Screen.ORIENTATION_LANDSCAPE, Screen.ORIENTATION_PORTRAIT_ROTATED},
                args = {Screen.ORIENTATION_LANDSCAPE_ROTATED, Screen.ORIENTATION_PORTRAIT, Screen.ORIENTATION_LANDSCAPE, Screen.ORIENTATION_PORTRAIT_ROTATED},
                default_arg = 0,
                current_func = function() return Screen:getRotationMode() end,
                event = "SetRotationMode",
                name_text_hold_callback = optionsutil.showValues,
            }
        }
    },
    {
        icon = "resources/icons/appbar.crop.large.png",
        options = {
            {
                name = "trim_page",
                name_text = _("Page Crop"),
                -- manual=0, auto=1, semi-auto=2, none=3
                -- ordered from least to max cropping done or possible
                toggle = {_("none"), _("auto"), _("semi-auto"), _("manual")},
                alternate = false,
                values = {3, 1, 2, 0},
                default_value = DKOPTREADER_CONFIG_TRIM_PAGE,
                enabled_func = Device.isTouchDevice,
                event = "PageCrop",
                args = {"none", "auto", "semi-auto", "manual"},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Allows cropping blank page margins in the original document.
This might be needed on scanned documents, that may have speckles or fingerprints in the margins, to be able to use zoom to fit content width.
- 'none' does not cut the original document margins.
- 'auto' finds content area automatically.
- 'semi-auto" finds content area automatically, inside some larger area defined manually.
- 'manual" uses the area defined manually as-is.

In 'semi-auto' and 'manual' modes, you may need to define areas once on an odd page number, and once on an even page number (these areas will then be used for all odd, or even, page numbers).]]),
            },
            {
                name = "page_margin",
                name_text = _("Margin"),
                toggle = {_("small"), _("medium"), _("large")},
                values = {0.05, 0.10, 0.25},
                default_value = DKOPTREADER_CONFIG_PAGE_MARGIN,
                event = "MarginUpdate",
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set margins to be applied after page-crop and zoom modes are applied.]]),
            },
        }
    },
    {
        icon = "resources/icons/appbar.page.fit.png",
        options = {
            {
                name = "zoom_overlap_h",
                name_text = _("Horizontal overlap"),
                buttonprogress = true,
                fine_tune = true,
                values = {0, 12, 24, 36, 48, 60, 72, 84},
                default_pos = 4,
                default_value = 36,
                show_func = function(config)
                    return config and config.zoom_mode_genus < 3
                end,
                event = "DefineZoom",
                args =   {0, 12, 24, 36, 48, 60, 72, 84},
                labels = {0, 12, 24, 36, 48, 60, 72, 84},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set horizontal zoom overlap (between columns).]]),
            },
            {
                name = "zoom_overlap_v",
                name_text = _("Vertical overlap"),
                buttonprogress = true,
                fine_tune = true,
                values = {0, 12, 24, 36, 48, 60, 72, 84},
                default_pos = 4,
                default_value = 36,
                show_func = function(config)
                    return config and config.zoom_mode_genus < 3
                end,
                event = "DefineZoom",
                args =   {0, 12, 24, 36, 48, 60, 72, 84},
                labels = {0, 12, 24, 36, 48, 60, 72, 84},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set vertical zoom overlap (between lines).]]),
            },
            {
                name = "zoom_mode_type",
                name_text = _("Fit"),
                toggle = {_("full"), _("width"), _("height")},
                alternate = false,
                values = {2, 1, 0},
                default_value = 2,
                show_func = function(config) return config and config.zoom_mode_genus > 2 end,
                event = "DefineZoom",
                args = {"full", "width", "height"},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set what to fit.]]),
            },
            {
                name = "zoom_range_number",
                name_text_func = function(config)
                    if config then
                        if config.zoom_mode_genus == 1 then return _("Rows")
                        elseif config.zoom_mode_genus == 2 then return _("Columns")
                        end
                    end
                    return _("Number")
                end,
                name_text_true_values = true,
                show_true_value_func = function(str)
                    return string.format("%.1f", str)
                end,
                toggle =  {_("1"), _("2"), _("3"), _("4"), _("5"), _("6"), _("7"), _("8")},
                more_options = true,
                more_options_param = {
                    value_step = 0.1, value_hold_step = 1,
                    value_min = 0.1, value_max = 1000,
                    precision = "%.1f",
                },
                values = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0},
                default_pos = 2,
                default_value = 2,
                show_func = function(config)
                    return config and config.zoom_mode_genus < 3 and config.zoom_mode_genus > 0
                end,
                event = "DefineZoom",
                args =   {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set the number of columns or rows into which to split the page.]]),
            },
            {
                name = "zoom_factor",
                name_text = _("Zoom factor"),
                name_text_true_values = true,
                show_true_value_func = function(str)
                    return string.format("%.1f", str)
                end,
                toggle =  {_("0.7"), _("1"), _("1.5"), _("2"), _("3"), _("5"), _("10"), _("20")},
                more_options = true,
                more_options_param = {
                    value_step = 0.1, value_hold_step = 1,
                    value_min = 0.1, value_max = 1000,
                    precision = "%.1f",
                },
                values = {0.7, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0},
                default_pos = 3,
                default_value = 1.5,
                show_func = function(config)
                    return config and config.zoom_mode_genus < 1
                end,
                event = "DefineZoom",
                args = {0.7, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 20.0},
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "zoom_mode_genus",
                name_text = _("Zoom to"),
                -- toggle = {_("page"), _("content"), _("columns"), _("rows"), _("manual")},
                item_icons = {
                    "resources/icons/zoom.page.png",
                    "resources/icons/zoom.content.png",
                    "resources/icons/zoom.direction.column.png",
                    "resources/icons/zoom.direction.row.png",
                    "resources/icons/zoom.manual.png",
                },
                alternate = false,
                values = {4, 3, 2, 1, 0},
                default_value = 4,
                event = "DefineZoom",
                args = {"page", "content", "columns", "rows", "manual"},
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "zoom_direction",
                name_text = _("Direction"),
                enabled_func = function(config)
                    return config.zoom_mode_genus < 3
                end,
                item_icons = {
                    "resources/icons/direction.LRTB.png",
                    "resources/icons/direction.TBLR.png",
                    "resources/icons/direction.LRBT.png",
                    "resources/icons/direction.BTLR.png",
                    "resources/icons/direction.BTRL.png",
                    "resources/icons/direction.RLBT.png",
                    "resources/icons/direction.TBRL.png",
                    "resources/icons/direction.RLTB.png",
                },
                alternate = false,
                values = {7, 6, 5, 4, 3, 2, 1, 0},
                default_value = 7,
                event = "DefineZoom",
                args = {7, 6, 5, 4, 3, 2, 1, 0},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set how paging and swiping forward should move the view on the page:
left to right or reverse, top to bottom or reverse.]]),
            },
        }
    },
    {
        icon = "resources/icons/appbar.column.two.large.png",
        options = {
            {
                name = "page_scroll",
                name_text = _("View Mode"),
                toggle = {_("page"), _("continuous")},
                values = {0, 1},
                default_value = 1,
                event = "SetScrollMode",
                args = {false, true},
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[- 'page' mode shows only one page of the document at a time.
- 'continuous' mode allows you to scroll the pages like you would in a web browser.]]),
            },
            {
                name = "page_gap_height",
                name_text = _("Page Gap"),
                toggle = {_("none"), _("small"), _("medium"), _("large")},
                values = {0, 8, 16, 32},
                default_value = 8,
                args = {0, 8, 16, 32},
                event = "PageGapUpdate",
                enabled_func = function (configurable)
                    return optionsutil.enableIfEquals(configurable, "page_scroll", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In continuous view mode, sets the thickness of the separator between document pages.]]),
            },
            {
                name = "full_screen",
                name_text = _("Progress Bar"),
                toggle = {_("off"), _("on")},
                values = {1, 0},
                default_value = 1,
                event = "SetFullScreen",
                args = {true, false},
                show = false, -- toggling bottom status can be done via tap
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "line_spacing",
                name_text = _("Line Spacing"),
                toggle = {_("small"), _("medium"), _("large")},
                values = {1.0, 1.2, 1.4},
                default_value = DKOPTREADER_CONFIG_LINE_SPACING,
                advanced = true,
                enabled_func = function(configurable)
                    -- seems to only work in reflow mode
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the spacing between lines.]]),
            },
            {
                name = "justification",
                --- @translators Text alignment. Options given as icons: left, right, center, justify.
                name_text = _("Alignment"),
                item_icons = {
                    "resources/icons/appbar.align.auto.png",
                    "resources/icons/appbar.align.left.png",
                    "resources/icons/appbar.align.center.png",
                    "resources/icons/appbar.align.right.png",
                    "resources/icons/appbar.align.justify.png",
                },
                values = {-1,0,1,2,3},
                default_value = DKOPTREADER_CONFIG_JUSTIFICATION,
                advanced = true,
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                labels = {
                    C_("Alignment", "auto"),
                    C_("Alignment", "left"),
                    C_("Alignment", "center"),
                    C_("Alignment", "right"),
                    C_("Alignment", "justify"),
                },
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the text alignment.
The first option ("auto") tries to automatically align reflowed text as it is in the original document.]]),
            },
        }
    },
    {
        icon = "resources/icons/appbar.text.size.large.png",
        options = {
            {
                name = "font_size",
                item_text = tableOfNumbersToTableOfStrings(FONT_SCALE_FACTORS),
                item_align_center = 1.0,
                spacing = 15,
                height = 60,
                item_font_size = FONT_SCALE_DISPLAY_SIZE,
                args = FONT_SCALE_FACTORS,
                values = FONT_SCALE_FACTORS,
                default_value = DKOPTREADER_CONFIG_FONT_SIZE,
                event = "FontSizeUpdate",
                enabled_func = function(configurable, document)
                    if document.is_reflowable then return true end
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
            },
            {
                name = "font_fine_tune",
                name_text = _("Font Size"),
                toggle = Device:isTouchDevice() and {_("decrease"), _("increase")} or nil,
                item_text = not Device:isTouchDevice() and {_("decrease"), _("increase")} or nil,
                values = {-0.05, 0.05},
                default_value = 0.05,
                event = "FineTuningFontSize",
                args = {-0.05, 0.05},
                alternate = false,
                enabled_func = function(configurable, document)
                    if document.is_reflowable then return true end
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = function(configurable, __, prefix)
                    local opt = {
                        name = "font_size",
                        name_text = _("Font Size"),
                        help_text = _([[In reflow mode, sets a font scaling factor that is applied to the original document font sizes.]]),
                    }
                    optionsutil.showValues(configurable, opt, prefix)
                end,
            },
            {
                name = "word_spacing",
                name_text = _("Word Gap"),
                toggle = {_("small"), _("auto"), _("large")},
                values = DKOPTREADER_CONFIG_WORD_SPACINGS,
                default_value = DKOPTREADER_CONFIG_DEFAULT_WORD_SPACING,
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the spacing between words.]]),
            },
            {
                name = "text_wrap",
                --- @translators Reflow text.
                name_text = _("Reflow"),
                toggle = {_("off"), _("on")},
                values = {0, 1},
                default_value = DKOPTREADER_CONFIG_TEXT_WRAP,
                events = {
                    {
                        event = "RedrawCurrentPage",
                    },
                    {
                        event = "RestoreZoomMode",
                    },
                    {
                        event = "InitScrollPageStates",
                    },
                },
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Reflow mode extracts text and images from the original document, possibly discarding some formatting, and reflows it on the screen for easier reading.
Some of the other settings are only available when reflow mode is enabled.]]),
            },
        }
    },
    {
        icon = "resources/icons/appbar.grade.b.large.png",
        options = {
            {
                name = "contrast",
                name_text = _("Contrast"),
                buttonprogress = true,
                -- See https://github.com/koreader/koreader/issues/1299#issuecomment-65183895
                -- For pdf reflowing mode (kopt_contrast):
                values = {1/0.8, 1/1.0, 1/1.5, 1/2.0, 1/4.0, 1/6.0, 1/10.0, 1/50.0},
                default_pos = 2,
                default_value = DKOPTREADER_CONFIG_CONTRAST,
                event = "GammaUpdate",
                -- For pdf non-reflowing mode (mupdf):
                args =   {0.8, 1.0, 1.5, 2.0, 4.0, 6.0, 10.0, 50.0},
                labels = {0.8, 1.0, 1.5, 2.0, 4.0, 6.0, 10.0, 50.0},
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "page_opt",
                name_text = _("Dewatermark"),
                toggle = {_("off"), _("on")},
                values = {0, 1},
                default_value = 0,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Remove watermarks from the rendered document.
This can also be used to remove some gray background or to convert a grayscale or color document to black & white and get more contrast for easier reading.]]),
            },
            {
                name = "hw_dithering",
                name_text = _("Dithering"),
                toggle = {_("off"), _("on")},
                values = {0, 1},
                default_value = 0,
                advanced = true,
                show = Device:hasEinkScreen() and Device:canHWDither(),
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Enable Hardware dithering.]]),
            },
            {
                name = "quality",
                name_text = C_("Quality", "Render Quality"),
                toggle = {C_("Quality", "low"), C_("Quality", "default"), C_("Quality", "high")},
                values={0.5, 1.0, 1.5},
                default_value = DKOPTREADER_CONFIG_RENDER_QUALITY,
                advanced = true,
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the quality of the text and image extraction processing and output.]]),
            },
        }
    },
    {
        icon = "resources/icons/appbar.settings.large.png",
        options = {
            {
                name="doc_language",
                name_text = _("Document Language"),
                toggle = DKOPTREADER_CONFIG_DOC_LANGS_TEXT,
                values = DKOPTREADER_CONFIG_DOC_LANGS_CODE,
                default_value = DKOPTREADER_CONFIG_DOC_DEFAULT_LANG_CODE,
                event = "DocLangUpdate",
                args = DKOPTREADER_CONFIG_DOC_LANGS_CODE,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Set the language to be used by the OCR engine.]]),
            },
            {
                name = "forced_ocr",
                --- @translators If OCR is unclear, please see https://en.wikipedia.org/wiki/Optical_character_recognition
                name_text = _("Forced OCR"),
                toggle = {_("off"), _("on")},
                values = {0, 1},
                default_value = 0,
                advanced = true,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[Force the use of OCR for text selection, even if the document has a text layer.]]),
            },
            {
                name = "writing_direction",
                name_text = _("Writing Direction"),
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                toggle = {
                    --- @translators LTR is left to right, which is the regular European writing direction.
                    _("LTR"),
                    --- @translators RTL is right to left, which is the regular writing direction in languages like Hebrew, Arabic, Persian and Urdu.
                    _("RTL"),
                    --- @translators TBRTL is top-to-bottom-right-to-left, which is a traditional Chinese/Japanese writing direction.
                    _("TBRTL"),
                },
                values = {0, 1, 2},
                default_value = 0,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the original text direction. This needs to be set to RTL to correctly extract and reflow RTL languages like Arabic or Hebrew.]]),
            },
            {
                name = "defect_size",
                --- @translators The maximum size of a dust or ink speckle to be ignored instead of being considered a character.
                name_text = _("Reflow Speckle Ignore Size"),
                toggle = {_("small"), _("medium"), _("large")},
                values = {1.0, 3.0, 5.0},
                default_value = DKOPTREADER_CONFIG_DEFECT_SIZE,
                event = "DefectSizeUpdate",
                show = false, -- might work somehow, but larger values than 1.0 might easily eat content
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "auto_straighten",
                name_text = _("Auto Straighten"),
                toggle = {_("0 deg"), _("5 deg"), _("10 deg")},
                values = {0, 5, 10},
                default_value = DKOPTREADER_CONFIG_AUTO_STRAIGHTEN,
                show = false, -- does not work (and slows rendering)
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "detect_indent",
                name_text = _("Indentation"),
                toggle = {_("off"), _("on")},
                values = {0, 1},
                default_value = DKOPTREADER_CONFIG_DETECT_INDENT,
                show = false, -- does not work
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
            },
            {
                name = "max_columns",
                name_text = _("Document Columns"),
                item_icons = {
                    "resources/icons/appbar.column.one.png",
                    "resources/icons/appbar.column.two.png",
                    "resources/icons/appbar.column.three.png",
                },
                values = {1,2,3},
                default_value = DKOPTREADER_CONFIG_MAX_COLUMNS,
                enabled_func = function(configurable)
                    return optionsutil.enableIfEquals(configurable, "text_wrap", 1)
                end,
                name_text_hold_callback = optionsutil.showValues,
                help_text = _([[In reflow mode, sets the max number of columns to try to detect in the original document.
You might need to set it to 1 column if, in a full width document, text is incorrectly detected as multiple columns because of unlucky word spacing.]]),
            },
        }
    },
}

if BD.mirroredUILayout() then
    -- The justification items {AUTO, LEFT, CENTER, RIGHT, JUSTIFY} will
    -- be mirrored - but that's not enough: we need to swap LEFT and RIGHT,
    -- so they appear in a more expected and balanced order to RTL users:
    -- {JUSTIFY, LEFT, CENTER, RIGHT, AUTO}
    local j = KoptOptions[3].options[5]
    assert(j.name == "justification")
    j.item_icons[2], j.item_icons[4] = j.item_icons[4], j.item_icons[2]
    j.values[2], j.values[4] = j.values[4], j.values[2]
    j.labels[2], j.labels[4] = j.labels[4], j.labels[2]
end

return KoptOptions

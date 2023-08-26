const constants = {
    noResult: {
        l: "No results found",
        renderable: "No results found"
    },
    labels: {
        modules: 'Modules',
        packages: 'Packages',
        types: 'Types',
        members: 'Members',
        tags: 'SearchTags'
    }
}

//It is super important to have vars here since they are lifter outside the block
//ES6 syntax doesn't provide those feature and therefore will fail when one of those values wouldn't be initialized
//eg. when a request for a given package fails
if(typeof moduleSearchIndex === 'undefined'){
    var moduleSearchIndex;
}
if(typeof packageSearchIndex === 'undefined'){
    var packageSearchIndex;
}
if(typeof typeSearchIndex === 'undefined'){
    var typeSearchIndex;
}
if(typeof memberSearchIndex === 'undefined'){
    var memberSearchIndex;
}
if(typeof tagSearchIndex === 'undefined'){
    var tagSearchIndex;
}

const clearElementValue = (element) => {
    element.val('')
}

$(function init() {
    const search = $("#search")
    const reset = $("#reset")

    clearElementValue(search)
    reset.on('click', () => {
        clearElementValue(search)
        search.focus()
    })
})

const itemHasResults = (item) => {
    return item.l !== constants.noResult
}

$.widget("custom.catcomplete", $.ui.autocomplete, {
    _create: function() {
        this._super();
    },
    _renderMenu: function(ul, items) {
        const menu = this;
        let category
        $.each(items, (index, item) => {
            const shouldCategoryLabelBeRendered = itemHasResults(item) && item.category !== category
            if (shouldCategoryLabelBeRendered) {
                ul.append(`<li class="ui-autocomplete-category">${item.category}</li>`);
                category = item.category;
            }

            const li = menu._renderItemData(ul, item);
            if (item.category) {
                li.attr("aria-label", `${item.category} : ${item.l}`);
            } else {
                li.attr("aria-label", item.l);
            }
            li.attr("class", "resultItem");
        });
    },
    _renderItem: (ul, item) => {
        const li = $("<li/>").appendTo(ul);
        const div = $("<div/>").appendTo(li);
        div.html(item.renderable);
        return li;
    }
});

const highlight = (match) => `<span class="resultHighlight">` + match + `</span>`
const escapeHtml = (str) => str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

const labelForPackage = (element) => (element.m) ? (element.m + "/" + element.l) : element.l
const labelForNested = (element) => {
    var label = ""
    if(element.p) label += `${element.p}.`
    if(element.l !== element.c && element.c) label += `${element.c}.`
    return label + element.l
}
const nestedName = (e) => e.l.substring(e.l.lastIndexOf(".") + 1)

const renderableFromLabel = (label, regex) => escapeHtml(label).replace(regex, highlight)

$(() => {
    $("#search").catcomplete({
        minLength: 1,
        delay: 100,
        source: function(request, response) {
            const exactRegexp = $.ui.autocomplete.escapeRegex(request.term) + "$"
            const exactMatcher = new RegExp("^" + exactRegexp, "i");
            const camelCaseRegexp = ($.ui.autocomplete.escapeRegex(request.term)).split(/(?=[A-Z])/).join("([a-z0-9_$]*?)");
            const camelCaseMatcher = new RegExp("^" + camelCaseRegexp);
            const secondaryMatcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");

            const processWithExactLabel = (dataset, category) => {
                const exactOrCamelMatches = []
                const secondaryMatches = []

                dataset.map(element => {
                    element.category = category
                    return element
                }).forEach((element) => {
                    if(exactMatcher.test(element.l)){
                        element.renderable = renderableFromLabel(element.l, exactMatcher)
                        exactOrCamelMatches.push(element)
                    } else if(camelCaseMatcher.test(element.l)){
                        element.renderable = renderableFromLabel(element.l, camelCaseMatcher)
                        exactOrCamelMatches.push(element)
                    } else if(secondaryMatcher.test(element.l)){
                        element.renderable = renderableFromLabel(element.l, secondaryMatcher)
                        secondaryMatches.push(element)
                    }
                })

                return [...exactOrCamelMatches, ...secondaryMatches]
            }

            const processPackages = (dataset) => {
                const exactOrCamelMatches = []
                const secondaryMatches = []

                dataset.map(element => {
                    element.category = constants.labels.packages
                    return element
                }).forEach((element) => {
                    const label = labelForPackage(element);
                    if(exactMatcher.test(element.l)){
                        element.renderable = renderableFromLabel(element.l, exactMatcher)
                        exactOrCamelMatches.push(element)
                    } else if(camelCaseMatcher.test(label)){
                        element.renderable = renderableFromLabel(label, camelCaseMatcher)
                        exactOrCamelMatches.push(element)
                    } else if(secondaryMatcher.test(label)){
                        element.renderable = renderableFromLabel(label, secondaryMatcher)
                        secondaryMatches.push(element)
                    }
                })

                return [...exactOrCamelMatches, ...secondaryMatches]
            }

            const processNested = (dataset, label) => {
                const exactOrCamelMatches = []
                const secondaryMatches = []

                dataset.map(element => {
                    element.category = label
                    return element
                }).forEach((element) => {
                    const label = nestedName(element);
                    if(exactMatcher.test(label)) {
                        element.renderable = renderableFromLabel(labelForNested(element), new RegExp(exactRegexp, "i"))
                        exactOrCamelMatches.push(element)
                    } else if(camelCaseMatcher.test(label)){
                        element.renderable = renderableFromLabel(labelForNested(element), new RegExp(camelCaseRegexp))
                        exactOrCamelMatches.push(element)
                    } else if(secondaryMatcher.test(labelForNested(element))){
                        element.renderable = renderableFromLabel(labelForNested(element), secondaryMatcher)
                        secondaryMatches.push(element)
                    }
                })

                return [...exactOrCamelMatches, ...secondaryMatches]
            }

            const modules = moduleSearchIndex ? processWithExactLabel(moduleSearchIndex, constants.labels.modules) : []
            const packages = packageSearchIndex ? processPackages(packageSearchIndex) : []
            const types = typeSearchIndex ? processNested(typeSearchIndex, constants.labels.types) : []
            const members = memberSearchIndex ? processNested(memberSearchIndex, constants.labels.members) : []
            const tags = tagSearchIndex ? processWithExactLabel(tagSearchIndex, constants.labels.tags) : []

            const result = [...modules, ...packages, ...types, ...members, ...tags]
            return response(result);
        },
        response: function(event, ui) {
            if (!ui.content.length) {
                ui.content.push(constants.noResult);
            } else {
                $("#search").empty();
            }
        },
        autoFocus: true,
        position: {
            collision: "flip"
        },
        select: function(event, ui) {
            if (ui.item.l !== constants.noResult.l) {
                window.location.href = pathtoroot + ui.item.url;
                $("#search").focus();
            }
        }
    });
});


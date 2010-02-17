jQuery.fn.versionSelector = function(versions, sizes) {
    $(this).each(function() {
        new jQuery.versionSelector(this, versions, sizes);
    })
}

jQuery.versionSelector = function(element, versions, sizes) {
    var _this = this,
        guid = 0;
    
    
    this.init = function() {
        this.selects = [];
        this.inputs = [];
        this.unknownSize = false;
        
        this.gemVersions = [];
        for (var i=0, l = versions.length; i < l; i++) {
            switch (versions[i].name.toLowerCase()) {
                case 'ruby':
                    this.rubyVersions = versions[i];
                    break;
                case 'rails':
                    this.railsVersions = versions[i];
                    break;
                default:
                    this.gemVersions.push(versions[i]);
            }
        };
        $('.preset_rails', element).triggerHandler('click');
    }
    
    this.bindEvents = function() {
        $('.preset', element).click(this.presetClick);
        $('#download, #browse').click(this.downloadClick);
    }
    
    this.downloadClick = function() {
        if (_this.unknownSize) $('.build-message').show()
    }
    
    this.presetClick = function() {
        if ($(this).hasClass('preset_ruby')) {
            _this.setHrefs([
                [_this.railsVersions.href, _this.railsVersions.versions[0]],
                [_this.rubyVersions.href, _this.rubyVersions.versions[0]]
            ]);
            _this.close();
        } else if ($(this).hasClass('preset_rails')) {
            _this.setHrefs([
                [_this.railsVersions.href, _this.railsVersions.versions[0]]
            ]);
            _this.close();
        } else {
            _this.open();
        }
        
        $('.preset_selected', element).removeClass('preset_selected');
        $(this).addClass('preset_selected');
    }
    
    this.close = function() {
        if (this.$form) {
            this.$form.slideUp('slow');
        }
    }
    
    this.open = function() {
        if (!this.$form) {
            this.render();
        }
        this.$form.slideDown('slow');
        this.rebuildHrefs();
    }
    
    this.render = function() {
        if (this.$form) return;
        var div = document.createElement('div'),
            item, 
            col1 = document.createElement('div'), 
            col2 = document.createElement('div'),
            h3 = document.createElement('h3'),
            clear = document.createElement('div');
        div.className = 'packages';
        div.style.display = 'none';
        col1.className = 'column';
        col2.className = 'column';
        clear.className = 'clear';
        h3.innerHTML = 'Gems';
        
        
        item = this.renderItem(this.selects, this.inputs, this.railsVersions, true);
        div.appendChild(item);
        item = this.renderItem(this.selects, this.inputs, this.rubyVersions, true)
        div.appendChild(item);
        div.appendChild(h3);
        div.appendChild(col1);
        div.appendChild(col2);
        div.appendChild(clear);
        
        for (var i=0, l = this.gemVersions.length; i < l; i++) {
            item = this.renderItem(this.selects, this.inputs, this.gemVersions[i]);
            var target = i < l / 2 ? col1 : col2;
            target.appendChild(item);
        };
        this.element.appendChild(div);
        this.$form = $(div);
        this.bindRendered();
    }
    
    this.bindRendered = function() {
        $(this.selects).each(function() {
            $(this).change(function() {_this.rebuildHrefs()});
        })
        $(this.inputs).each(function() {
            $(this).click(function() {_this.rebuildHrefs()});
        })
    }
    
    this.renderItem = function(selects, inputs, version, checked) {
        var p = document.createElement('p'),
            id = guid++, select, input, option, versions = version.versions;
        p.innerHTML = 
            '<input type="checkbox" id="item_' + id + '" />'
            + '<label for="item_' + id + '">' + version.name + '</label> ';
        if (versions.length > 1) {
            p.innerHTML += '<select id="item_select_' + id + '"></select>';
            select = p.getElementsByTagName('select')[0];
            for (var i=0, l = versions.length; i < l; i++) {
                option = document.createElement('option');
                option.value = versions[i];
                option.innerHTML = versions[i];
                select.appendChild(option);
            };
        } else {
            p.innerHTML += '<input type="hidden" value="' + versions[0] + '"> ' + versions[0];
            select = p.getElementsByTagName('input')[1];
        }
        $(select).data('href', version.href);
        input = p.getElementsByTagName('input')[0];
        if (checked) input.checked = input.defaultChecked = true;
        inputs.push(input);
        selects.push(select);
        return p;
    }
    
    this.rebuildHrefs = function() {
        var items = [], select;
        for (var i=0, l = this.inputs.length; i < l; i++) {
            if(this.inputs[i].checked) {
                select = this.selects[i];
                items.push([$(select).data('href'), select.value]);
            }
        };
        this.setHrefs(items);
    }
    
    this.setHrefs = function(items) {
        var parts = [], item, path;
        for (var i=0, l = items.length; i < l; i++) {
            item = items[i]
            parts[parts.length] = item[0].replace(/[_-]/g, '') + '-' + item[1].replace(/[_-]/g, '');
        };
        path = parts.sort().join('_');
        if (parts.length) {
            $('#download').attr('href', '/doc/' + path + '/rdoc.zip');
            $('#browse').attr('href', '/doc/' + path + '/');
            this.unknownSize = !this.sizes[path];
        } else {
            $('#download').attr('href', '#');
            $('#browse').attr('href', '#');
            this.unknownSize = false;
        }
        $('#size').html('Zip, ' + (this.sizes[path] || 'unknown size'));
    }
    
    this.element = element;
    this.sizes = sizes;
    this.bindEvents();
    this.init();
    
    if (location.hash.indexOf('custom') != -1) {
        $('.preset:eq(2)', element).click();
    }
}

###
Copyright (c) 2002-2013 "Neo Technology,"
Network Engine for Objects in Lund AB [http://neotechnology.com]

This file is part of Neo4j.

Neo4j is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

define(
  ['neo4j/webadmin/modules/databrowser/models/PropertyContainer'
   'neo4j/webadmin/modules/databrowser/models/DataBrowserState'
   'ribcage/View'
   './propertyEditor'
   'lib/amd/jQuery'], 
  (PropertyContainer, DataBrowserState, View, propertyEditorTemplate, $) ->

    class PropertyContainerView extends View

      events :
        "keyup input.property-key"     : "keyChanged",
        "keyup input.property-value"   : "valueChanged",
        "change input.property-key"    : "keyChangeDone",
        "change input.property-value"  : "valueChangeDone",
        "click .get-course-file"       : "getFile",
        "click .data-save-properties"  : "saveChanges"

      initialize : (opts) =>
        @template = opts.template
        @dataModel = opts.dataModel
        @_href = "" # RAfzalan href for course documents

      keyChanged : (ev) =>
        id = @getPropertyIdForElement(ev.target)
        if $(ev.target).val() != @propertyContainer.getProperty(id).getKey()
          @propertyContainer.setNotSaved()

      valueChanged : (ev) =>
        id = @getPropertyIdForElement(ev.target)
        if $(ev.target).val() != @propertyContainer.getProperty(id).getValueAsJSON()
          prop = @propertyContainer.setNotSaved()

      keyChangeDone : (ev) =>
        id = @getPropertyIdForElement(ev.target)
        @propertyContainer.setKey(id, $(ev.target).val())
        @saveChanges()
        @updateErrorMessages()

      valueChangeDone : (ev) =>    
        id = @getPropertyIdForElement(ev.target)
        el = $(ev.target)

        if @shouldBeConvertedToString(el.val())
          el.val('"' + el.val() + '"');
        
        @propertyContainer.setValue(id, el.val())
        @saveChanges()
        @updateErrorMessages()

      getFile : (ev) => # RAfzalan
        if @_href != ''
          ev.preventDefault() #  stop the browser from following
          window.location.href = @_href
        # a = document.createElement('a')
        # a.href = @_href
        # a.download = "Course_Contents" # not work
        # $(a).attr("download",@_href) # not work
        # window.location = a 

      doesFileExist = (urlToFile) -> # RAfzalan
        xhr = new XMLHttpRequest()
        xhr.open "HEAD", urlToFile, false
        xhr.send()
        if xhr.status is 200
          true
        else
          false

      saveChanges : (ev) =>
        @propertyContainer.save()

      updateErrorMessages : () =>
        for row in $("ul.property-row",@el)
          id =$(row).find("input.property-id").val()
          prop = @propertyContainer.getProperty(id)
          if prop
            keyErrorEl = $(row).find(".property-key-wrap .form-error")
            valueErrorEl = $(row).find(".property-value-wrap .form-error")
            if prop.hasKeyError() 
              keyErrorEl.html(prop.getKeyError())
              keyErrorEl.show()
            else keyErrorEl.hide()
            
            if prop.hasValueError() 
              valueErrorEl.html(prop.getValueError())
              valueErrorEl.show()
            else valueErrorEl.hide()
            
      updateSaveState : (ev) =>
        state = @propertyContainer.getSaveState()
        switch state
          when "notSaved" then @setSaveState "Save",     false
          when "saving"   then @setSaveState "Saving..", true
          when "cantSave" then @setSaveState "Save",     true
          when "saved" 
            @setSaveState "Saved", true
            # A bit of domain logic in the presentation logic. Will be 
            # fixed as part of refactoring the domain model.
            if @dataModel.getState() == DataBrowserState.State.ERROR
              # The data model is in an error state, but we have successfully saved the
              # current state, so update the data model with our state to get it back in 
              # business.
              @dataModel.setData(@propertyContainer.item)

      setSaveState : (text, disabled) =>
        button = $(".data-save-properties", @el)
        button.html(text)
        if disabled
          button.attr("disabled","disabled")
        else
          button.removeAttr("disabled")
        
      getPropertyIdForElement : (element) =>
        $(element).closest("ul").find("input.property-id").val()

      setData : (@propertyContainer) =>
        @unbind()
        @propertyContainer.bind "remove:property", @renderProperties
        @propertyContainer.bind    "add:property", @renderProperties
        @propertyContainer.bind   "change:status", @updateSaveState

      render : =>
        $(@el).html(@template(
          item : @propertyContainer
        ))
        @renderProperties()
        courseCodeProp = @propertyContainer.getPropertyByKey("كد_دوره")
        courseCode = if courseCodeProp then courseCodeProp.getValue().toString() else null
        @_href = ''
        if courseCode? and (courseCode.length is 5)
          @_href = 'docx/' + courseCode.substr(0,3) + '/' + parseInt(courseCode.substr(3,2)).toString()
          if (doesFileExist (@_href+'.docx'))
            @_href+='.docx'
          else
            if (doesFileExist (@_href+'.doc'))
              @_href+='.doc'
            else
              @_href = ''
        if @_href is ''
          $(".get-course-file", @el).attr("disabled", "disabled") # RAfzalan
        else
          $(".get-course-file", @el).removeAttr("disabled", true) # RAfzalan
        return this

      renderProperties : =>
        $(".properties",@el).html(propertyEditorTemplate(
          properties : @propertyContainer.get "propertyList"
        ))

        return this

      remove : =>
        @unbind()
        super()

      unbind : =>
        if @propertyContainer?
          @propertyContainer.unbind "remove:property", @renderProperties
          @propertyContainer.unbind "add:property", @renderProperties
          @propertyContainer.unbind "change:status", @updateSaveState

      stringRegex : /// ^ 
                    [^
                      (^(\d+)(‎\.(\d+))?$) # Not stuff that looks like numbers
                      (^\[(.*)\]$)        # Not stuff that looks like an array
                    ]
                    ///i
      shouldBeConvertedToString : (val) =>
        try 
          JSON.parse val
          return false
        catch e
          return @stringRegex.test(val)
)

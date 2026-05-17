macroscript my3dmaxtoRev category:"MUSTBE Tools" (

  global g_exportQueue = #()
  global g_layerMap = #()

  rollout layerEditRollout "Edit Layers" width:320 height:450 (
    label    'lbl1' "Click layer to select objects. Edit name if needed." pos:[10,5] width:300 height:30
    listbox  'lbLayers' "Layers:" pos:[10,40]  width:300 height:14
    label    'lbl2' "Layer name:" pos:[10,270] width:80  height:19
    edittext 'edtName' ""         pos:[10,290] width:300 height:25
    button   'btnRename' "Set Name"  pos:[10,325] width:145 height:25 align:#left
    button   'btnSelect' "Select"    pos:[165,325] width:145 height:25 align:#left
    button   'btnExport' "Export"    pos:[10,365] width:300 height:40
    button   'btnCancel' "Cancel"    pos:[10,415] width:300 height:25

    on layerEditRollout open do (
      local names = #()
      for pair in g_layerMap do append names (pair[1] + "  ->  " + pair[2])
      lbLayers.items = names
    )

    on lbLayers selected idx do (
      local layerName = g_layerMap[idx][1]
      local layerObjs = #()
      for o in objects do (
        if o.layer != undefined and o.layer.name == layerName do
          append layerObjs o
      )
      if layerObjs.count > 0 then (
        select layerObjs
        edtName.text = g_layerMap[idx][2]
      ) else (
        messageBox ("No objects on layer: " + layerName) title:"Info"
      )
    )

    on btnRename pressed do (
      if lbLayers.selection > 0 do (
        local newName = edtName.text
        if newName != "" do (
          g_layerMap[lbLayers.selection][2] = newName
          local names = #()
          for pair in g_layerMap do append names (pair[1] + "  ->  " + pair[2])
          lbLayers.items = names
          lbLayers.selection = lbLayers.selection
        )
      )
    )

    on btnSelect pressed do (
      if lbLayers.selection > 0 do (
        local layerName = g_layerMap[lbLayers.selection][1]
        local layerObjs = #()
        for o in objects do (
          if o.layer != undefined and o.layer.name == layerName do
            append layerObjs o
        )
        if layerObjs.count > 0 do select layerObjs
      )
    )

    on btnExport pressed do (
      -- ????????? ?????????????? ????? ????? ?????????
      for pair in g_layerMap do (
        local oldName = pair[1]
        local newName = pair[2]
        if oldName != newName do (
          local newNL = LayerManager.getLayerFromName newName
          if newNL == undefined do newNL = LayerManager.newLayerFromName newName

          for o in objects do (
            if o.layer != undefined and o.layer.name == oldName do
              newNL.addNode o
          )
        )
      )

      local exportedFiles = #()
      for q in g_exportQueue do (
        local exportArray = q[1]
        local exportName  = if q[2] == undefined or q[2] == "" then "export" else q[2]
        local savePath    = q[3]
        local formatState = q[4]

        if exportArray.count > 0 do (
          select exportArray

          local pathNam = ""
          if formatState == 1 then (
            pathNam = savePath + "\\" + exportName + ".dxf"
            exportFile pathNam #noPrompt selectedOnly:true using:ACAD_DXF
          ) else (
            pathNam = savePath + "\\" + exportName + ".obj"
            exportFile pathNam #noPrompt selectedOnly:true using:ObjExp
          )
          print ("Exported: " + pathNam)
          append exportedFiles pathNam
        )
      )
      destroyDialog layerEditRollout
      messageBox ("??????? ????????!\n" + exportedFiles.count as string + " ??????") title:"??????"
    )

    on btnCancel pressed do (
      destroyDialog layerEditRollout
    )
  )

  rollout unnamedRollout "my3dmaxToRevit" width:220 height:340 (
    button       'btn1' "Export"                   pos:[26,37]  width:167 height:59  align:#left
    edittext     'edt2' ""                         pos:[21,127] width:167 height:31  align:#left
    label        'lbl2' "Family Name:"             pos:[26,103] width:95  height:19  align:#left
    label        'lbl3' "Export to Revit:"         pos:[25,7]   width:115 height:31  align:#left
    radiobuttons 'rdoFormat' "Format:"             pos:[26,185] width:167 labels:#("DXF", "OBJ") default:1 align:#left
    checkbox     'chkSplit'  "Split by BBox"       pos:[26,220] width:167 align:#left
    checkbox     'chkGroups' "Groups as Furniture" pos:[26,242] width:167 align:#left
    label        'lbl4' "Save Path:"               pos:[26,268] width:60  height:19  align:#left
    button       'btnPath' "..."                   pos:[183,265] width:30 height:21  align:#left
    edittext     'edtPath' ""                      pos:[21,288] width:192 height:31  align:#left

    global ObjName
    global lastSavePath

    on unnamedRollout open do (
      if lastSavePath == undefined or lastSavePath == "" then (
        local userProfile = dotNetClass "System.Environment"
        lastSavePath = userProfile.GetFolderPath (dotNetClass "System.Environment+SpecialFolder").MyDocuments
      )
      edtPath.text = lastSavePath
    )

    on btnPath pressed do (
      local newPath = getSavePath caption:"???????? ????? ??? ??????????" initialDir:lastSavePath
      if newPath != undefined then (
        lastSavePath = newPath
        edtPath.text = newPath
      )
    )

    on edtPath entered text do (
      lastSavePath = text
    )

    fn bboxIntersects obj1 obj2 = (
      local min1 = obj1.min
      local max1 = obj1.max
      local min2 = obj2.min
      local max2 = obj2.max
      (max1.x >= min2.x and min1.x <= max2.x) and
      (max1.y >= min2.y and min1.y <= max2.y) and
      (max1.z >= min2.z and min1.z <= max2.z)
    )

    fn groupByBBox objArray = (
      local groups = #()
      local assigned = #()
      for i = 1 to objArray.count do assigned[i] = false

      for i = 1 to objArray.count do (
        if not assigned[i] do (
          local group = #(objArray[i])
          assigned[i] = true

          local changed = true
          while changed do (
            changed = false
            for j = 1 to objArray.count do (
              if not assigned[j] do (
                for g in group do (
                  if bboxIntersects g objArray[j] do (
                    append group objArray[j]
                    assigned[j] = true
                    changed = true
                    exit
                  )
                )
              )
            )
          )
          append groups group
        )
      )
      groups
    )

    fn attachObjects objArray = (
      select objArray
      convertTo $ Editable_Poly

      while selection.count > 1 do (
        selcount = selection.count
        for i = selcount to 2 by -2 do (
          polyop.attach selection[i] selection[i-1]
        )
      )
      update selection[1]
      selection[1]
    )

    fn processMesh obj exportName savePath formatState = (
      convertTo obj Editable_Mesh

      matNames = #()
      mat = obj.material
      if mat == undefined then (
        -- ??? ?????????
      ) else if classOf mat == Multimaterial then (
        for i = 1 to mat.numsubs do (
          if mat[i] != undefined and mat[i].name != "" then
            matNames[i] = mat[i].name
          else
            matNames[i] = "element" + i as string
        )
      ) else (
        local singleName = if mat.name != undefined and mat.name != "" then mat.name else "element"
        for i = 1 to 100 do matNames[i] = singleName
      )

      ExportArray = #()
      maxID = amax (for i = 1 to getNumFaces obj.mesh collect getFaceMatID obj.mesh i)
      x = 0

      for i = 1 to maxID do (
        o = i as string
        baseName = if matNames.count >= i and matNames[i] != undefined and matNames[i] != "" then matNames[i] else "element"
        layerName = baseName + "_" + o

        NL = LayerManager.getLayerFromName layerName
        if NL == undefined do NL = LayerManager.newLayerFromName layerName

        local found = false
        for pair in g_layerMap do if pair[1] == layerName do found = true
        if not found do append g_layerMap #(layerName, layerName)

        temp_arr = for j = 1 to getNumFaces obj.mesh where (getFaceMatID obj.mesh j) == i collect j
        x += 20

        if temp_arr.count != 0 do (
          aMesh = meshop.detachFaces obj.mesh temp_arr delete:true asMesh:true

          eMesh = mesh mesh:aMesh
          eMesh.transform = obj.transform
          convertTo eMesh Editable_Mesh

          for face = 1 to eMesh.numFaces do
            for edge = 1 to 3 do
              setEdgeVis eMesh face edge false
          update eMesh

          eMesh.name = obj.name + "_ID_" + (formattedPrint i format:"03d")
          NL.addNode eMesh
          eMesh.colorByLayer = on

          numFacePart = getNumFaces eMesh as float
          print ("Part: " + eMesh.name + " faces: " + numFacePart as string)

          if numFacePart > 32000 do (
            koff = 30000 / numFacePart * 100 as float
            print ("Optimizing: " + eMesh.name + " to " + koff as string + "%")
            select eMesh
            max modify mode
            local mod1 = ProOptimizer()
            addModifier eMesh mod1
            mod1.enabled = true
            mod1.VertexPercent = koff
            mod1.Calculate = true
            convertTo eMesh Editable_Mesh
            for face = 1 to eMesh.numFaces do
              for edge = 1 to 3 do
                setEdgeVis eMesh face edge false
            update eMesh
            print ("Result: " + (getNumFaces eMesh) as string + " faces")
          )

          append ExportArray eMesh
        )
      )

      -- ??????? ? ?????? ????????? ?????? ???? ???? ???????
      if ExportArray.count > 0 do (
        local totalMin = [1e9, 1e9, 1e9]
        local totalMax = [-1e9, -1e9, -1e9]

        for e in ExportArray do (
          if e.min.x < totalMin.x do totalMin.x = e.min.x
          if e.min.y < totalMin.y do totalMin.y = e.min.y
          if e.min.z < totalMin.z do totalMin.z = e.min.z
          if e.max.x > totalMax.x do totalMax.x = e.max.x
          if e.max.y > totalMax.y do totalMax.y = e.max.y
          if e.max.z > totalMax.z do totalMax.z = e.max.z
        )

        local centerX = (totalMin.x + totalMax.x) / 2.0
        local centerY = (totalMin.y + totalMax.y) / 2.0
        local bottomZ = totalMin.z
        local offset = [-centerX, -centerY, -bottomZ]

        for e in ExportArray do (
          move e offset
          update e
        )
      )

      local safeExportName = if exportName == undefined or exportName == "" then "export" else exportName
      append g_exportQueue #(ExportArray, safeExportName, savePath, formatState)
    )

    on btn1 pressed do (
      undo "Export to Revit" on (
        if ObjName == undefined or ObjName == "" then (
          messageBox "??????? Family Name!" title:"??????"
          return undefined
        )

        local savePath = edtPath.text
        if savePath == "" or savePath == undefined then (
          messageBox "??????? ????? ??? ??????????!" title:"??????"
          return undefined
        )

        if not doesFileExist savePath then (
          messageBox ("????? ?? ???????:\n" + savePath) title:"??????"
          return undefined
        )

        lastSavePath = savePath
        g_exportQueue = #()
        g_layerMap = #()

        local maxGroups = #()
        local singles = #()

        for obj in selection do (
          if isGroupHead obj then (
            append maxGroups obj
          ) else if not isGroupMember obj and not (classOf obj == Dummy) then (
            append singles obj
          )
        )

        if chkGroups.checked then (
          for grp in maxGroups do (
            local grpName = grp.name
            local grpObjs = #()
            for child in grp.children where not (classOf child == Dummy) do
              append grpObjs child
            explodeGroup grp

            if grpObjs.count > 0 do (
              local obj = attachObjects grpObjs
              processMesh obj grpName savePath rdoFormat.state
            )
          )

          if singles.count > 0 do (
            local obj = attachObjects singles
            processMesh obj ObjName savePath rdoFormat.state
          )

        ) else (
          for grp in maxGroups do (
            local grpObjs = #()
            for child in grp.children where not (classOf child == Dummy) do
              append grpObjs child
            explodeGroup grp
            for o in grpObjs do append singles o
          )

          if singles.count > 0 do (
            if chkSplit.checked then (
              local groups = groupByBBox singles
              for g in groups do (
                local groupName = ObjName + "_" + g[1].name
                local obj = attachObjects g
                processMesh obj groupName savePath rdoFormat.state
              )
            ) else (
              local obj = attachObjects singles
              processMesh obj ObjName savePath rdoFormat.state
            )
          )
        )

        createDialog layerEditRollout
      )
    )

    on edt2 entered text do (
      ObjName = text as string
    )
  )

  createDialog unnamedRollout
)
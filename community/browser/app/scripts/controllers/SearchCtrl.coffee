###!
Copyright (c) 2002-2014 "Neo Technology,"
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

'use strict';

angular.module("neo4jApp").controller "SearchCtrl",['$rootScope','$scope','Editor','$http','$log', ($rootScope, $scope, Edit, $http, $log) ->
  items = [
    "MATCH (n:دوره) WHERE n.عنوان_دوره =~ '(?i).*$0.*'  RETURN count(*)"
    "MATCH (n:گروه) WHERE n.عنوان_گروه_تخصصي =~ '(?i).*$0.*'  RETURN count(*)"
    "MATCH (n:دوره) WHERE n.اهداف_دوره =~ '(?i).*$0.*'  RETURN count(*)"
    "MATCH (n:محتوا) WHERE
      n.سر_فصل_1 =~ '(?i).*$0.*' OR
      n.سر_فصل_2 =~ '(?i).*$0.*' OR
      n.سر_فصل_3 =~ '(?i).*$0.*' OR
      n.سر_فصل_4 =~ '(?i).*$0.*' OR
      n.سر_فصل_5 =~ '(?i).*$0.*' OR
      n.سر_فصل_6 =~ '(?i).*$0.*' OR
      n.سر_فصل_7 =~ '(?i).*$0.*' OR
      n.سر_فصل_8 =~ '(?i).*$0.*' OR
      n.سر_فصل_9 =~ '(?i).*$0.*' OR
      n.سر_فصل_10 =~ '(?i).*$0.*' OR
      n.سر_فصل_11 =~ '(?i).*$0.*' OR
      n.سر_فصل_12 =~ '(?i).*$0.*' OR
      n.سر_فصل_13 =~ '(?i).*$0.*' OR
      n.سر_فصل_14 =~ '(?i).*$0.*' OR
      n.سر_فصل_15 =~ '(?i).*$0.*' OR
      n.سر_فصل_16 =~ '(?i).*$0.*' OR
      n.سر_فصل_17 =~ '(?i).*$0.*' OR
      n.سر_فصل_18 =~ '(?i).*$0.*' OR
      n.سر_فصل_19 =~ '(?i).*$0.*' OR
      n.سر_فصل_20 =~ '(?i).*$0.*' OR
      n.سر_فصل_21 =~ '(?i).*$0.*' OR
      n.سر_فصل_22 =~ '(?i).*$0.*' OR
      n.سر_فصل_23 =~ '(?i).*$0.*' OR
      n.سر_فصل_24 =~ '(?i).*$0.*' OR
      n.سر_فصل_25 =~ '(?i).*$0.*' OR
      n.سر_فصل_27 =~ '(?i).*$0.*' OR
      n.سر_فصل_28 =~ '(?i).*$0.*' OR
      n.سر_فصل_29 =~ '(?i).*$0.*' OR
      n.سر_فصل_30 =~ '(?i).*$0.*' OR
      n.سر_فصل_31 =~ '(?i).*$0.*' OR
      n.سر_فصل_32 =~ '(?i).*$0.*' OR
      n.سر_فصل_33 =~ '(?i).*$0.*' OR
      n.سر_فصل_34 =~ '(?i).*$0.*' OR
      n.سر_فصل_36 =~ '(?i).*$0.*' OR
      n.سر_فصل_37 =~ '(?i).*$0.*' OR
      n.سر_فصل_38 =~ '(?i).*$0.*' OR
      n.سر_فصل_39 =~ '(?i).*$0.*' OR
      n.سر_فصل_40 =~ '(?i).*$0.*' 
      RETURN count(*)
    "
    "MATCH (n:دوره) WHERE n.كد_دوره =~ '.*$0.*'  RETURN count(*)"
    "MATCH (n:دوره) WHERE n.کد_دوره_در_پتروشيمي =~ '.*$0.*'  RETURN count(*)"
  ]

  $scope.find = () ->
    $scope.runQuery()
    return
    
  $scope.go = (selectIndex) ->
    if $scope.result[selectIndex] > 0
      query = items[selectIndex].replace(/\$0/g, $scope.searchBoxVal).replace("RETURN count(*)", 'RETURN n')
      Edit.execScript(query)
    return

  $scope.change = ($event) ->
    $scope.searchBoxVal = $("#searchBox").val()
    if $("#searchBox").val().length > 3 or $event.which is 13
      $scope.result = [-1, -1, -1, -1, -1, -1]
      $scope.runQuery() 
    else
      $scope.result = null
    return

  $scope.result = null

  $scope.runQuery = ->
    i = 0
    max = 4
    max = 6 if $scope.searchBoxVal % 1 is 0
    while i < max
      $http.post("http://172.16.1.11:7474/db/data/cypher",
        query: items[i].replace(/\$0/g, $scope.searchBoxVal)
      ).success ((response) ->
        if $scope.result?
          $scope.result[@index] = response["data"]
        return
      ).bind(index: i)
      i++
    return
  return
]

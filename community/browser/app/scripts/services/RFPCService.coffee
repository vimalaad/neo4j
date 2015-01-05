###!
Copyright (c) 2002-2014 "Neo Technology,"
Network Engine for Objects in Lund AB [http://neotechnology.com]

This file is part of Neo4j.

Neo4j is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
buE id(user)=#{mergeUserResult.nodes[0].id} AND id(course)=#{courseNodeID} RETURN user;
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

'use strict';

angular.module('neo4jApp.services')
  .factory 'RFPCService', [
    '$q'
    'Cypher'
    ($q, Cypher) ->
      return  {

        mergeUser: (userAccount) ->
          q = $q.defer()
          Cypher.transaction()
          .commit("""
            MERGE (user:کاربر { نام_کاربری:#{userAccount} }) RETURN user;
            """
          )
          .then(q.resolve)
          q.promise

        mergeApplicant: (userAccount, courseNodeID) ->
          q = $q.defer()
          Cypher.transaction()
          .commit("""
            MATCH (user:کاربر),(course:دوره) 
            WHERE user.نام_کاربری=#{userAccount} AND id(course)=#{courseNodeID}
            MERGE (user -[:متقاضی]-> course)
            """
          )
          .then(q.resolve)
          q.promise

        removeApplicant: (userAccount, applicantID) ->
          q = $q.defer()
          Cypher.transaction()
          .commit("""
            MATCH (user -[r:متقاضی]-> course)
            WHERE user.نام_کاربری=#{userAccount} AND id(r)=#{applicantID}
            DELETE r
            """
          )
      }
  ]

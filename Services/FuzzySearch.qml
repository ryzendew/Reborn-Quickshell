pragma Singleton

import QtQuick
import Quickshell

/**
 * FuzzySearch - Fuzzy search and matching service based on Noctalia's Fuzzysort.js
 * Provides intelligent fuzzy matching for application names, icons, and desktop entries
 */
QtObject {
    id: root
    
    // Cache for prepared search terms and targets
    property var preparedCache: ({})
    property var preparedSearchCache: ({})
    
    /**
     * Main fuzzy search function
     * @param search - The search term
     * @param targets - Array of target strings or objects
     * @param options - Search options (key, keys, threshold, limit)
     * @returns Array of results with scores
     */
    function search(search, targets, options) {
        if (!search || !targets) {
            return options?.all ? targets : []
        }
        
        const preparedSearch = prepareSearch(search)
        const searchBitflags = preparedSearch.bitflags
        const containsSpace = preparedSearch.containsSpace
        const threshold = options?.threshold || 0
        const limit = options?.limit || Infinity
        const results = []
        let limitedCount = 0
        
        function pushResult(result) {
            if (results.length < limit) {
                results.push(result)
            } else {
                ++limitedCount
                if (result.score > results[results.length - 1].score) {
                    results[results.length - 1] = result
                    results.sort((a, b) => b.score - a.score)
                }
            }
        }
        
        // Handle different target types
        if (options?.key) {
            // Single key search
            const key = options.key
            for (let i = 0; i < targets.length; ++i) {
                const obj = targets[i]
                const target = getValue(obj, key)
                if (!target) continue
                
                const preparedTarget = prepare(target)
                if ((searchBitflags & preparedTarget.bitflags) !== searchBitflags) continue
                
                const result = algorithm(preparedSearch, preparedTarget)
                if (!result) continue
                if (result.score < threshold) continue
                
                result.obj = obj
                pushResult(result)
            }
        } else if (options?.keys) {
            // Multiple keys search
            const keys = options.keys
            for (let i = 0; i < targets.length; ++i) {
                const obj = targets[i]
                let bestScore = -Infinity
                let bestResult = null
                
                for (let j = 0; j < keys.length; ++j) {
                    const key = keys[j]
                    const target = getValue(obj, key)
                    if (!target) continue
                    
                    const preparedTarget = prepare(target)
                    if ((searchBitflags & preparedTarget.bitflags) !== searchBitflags) continue
                    
                    const result = algorithm(preparedSearch, preparedTarget)
                    if (result && result.score > bestScore) {
                        bestScore = result.score
                        bestResult = result
                    }
                }
                
                if (bestResult && bestResult.score >= threshold) {
                    bestResult.obj = obj
                    pushResult(bestResult)
                }
            }
        } else {
            // Direct string search
            for (let i = 0; i < targets.length; ++i) {
                const target = targets[i]
                if (!target) continue
                
                const preparedTarget = prepare(target)
                if ((searchBitflags & preparedTarget.bitflags) !== searchBitflags) continue
                
                const result = algorithm(preparedSearch, preparedTarget)
                if (!result) continue
                if (result.score < threshold) continue
                
                pushResult(result)
            }
        }
        
        results.sort((a, b) => b.score - a.score)
        results.total = results.length + limitedCount
        return results
    }
    
    /**
     * Single target fuzzy match
     * @param search - The search term
     * @param target - The target string
     * @returns Result object or null
     */
    function single(search, target) {
        if (!search || !target) return null
        
        const preparedSearch = prepareSearch(search)
        const preparedTarget = prepare(target)
        
        if ((preparedSearch.bitflags & preparedTarget.bitflags) !== preparedSearch.bitflags) {
            return null
        }
        
        return algorithm(preparedSearch, preparedTarget)
    }
    
    /**
     * Highlight matches in a string
     * @param result - Fuzzy search result
     * @param open - Opening tag
     * @param close - Closing tag
     * @returns Highlighted string
     */
    function highlight(result, open, close) {
        if (!result || !result.indexes) return result.target
        
        open = open || '**'
        close = close || '**'
        
        const target = result.target
        const indexes = result.indexes
        let highlighted = ''
        let matchIndex = 0
        
        for (let i = 0; i < target.length; ++i) {
            if (indexes[matchIndex] === i) {
                highlighted += open + target[i] + close
                matchIndex++
            } else {
                highlighted += target[i]
            }
        }
        
        return highlighted
    }
    
    /**
     * Prepare a target for searching
     * @param target - The target to prepare
     * @returns Prepared target object
     */
    function prepare(target) {
        if (typeof target === 'number') target = String(target)
        else if (typeof target !== 'string') target = String(target)
        
        // Check cache
        if (preparedCache[target]) {
            return preparedCache[target]
        }
        
        const info = prepareLowerInfo(target)
        const prepared = {
            target: target,
            targetLower: info.lower,
            targetLowerCodes: info.lowerCodes,
            bitflags: info.bitflags,
            containsSpace: info.containsSpace
        }
        
        preparedCache[target] = prepared
        return prepared
    }
    
    /**
     * Prepare a search term
     * @param search - The search term
     * @returns Prepared search object
     */
    function prepareSearch(search) {
        if (typeof search === 'number') search = String(search)
        else if (typeof search !== 'string') search = String(search)
        
        // Check cache
        if (preparedSearchCache[search]) {
            return preparedSearchCache[search]
        }
        
        const info = prepareLowerInfo(search)
        const prepared = {
            search: search,
            searchLower: info.lower,
            searchLowerCodes: info.lowerCodes,
            bitflags: info.bitflags,
            containsSpace: info.containsSpace,
            spaceSearches: info.containsSpace ? search.toLowerCase().split(/\s+/) : []
        }
        
        preparedSearchCache[search] = prepared
        return prepared
    }
    
    /**
     * Prepare lower case info for a string
     * @param str - The string to process
     * @returns Object with lower case info
     */
    function prepareLowerInfo(str) {
        str = removeAccents(str)
        const lower = str.toLowerCase()
        const lowerCodes = []
        let bitflags = 0
        let containsSpace = false
        
        for (let i = 0; i < str.length; ++i) {
            const lowerCode = lower.charCodeAt(i)
            lowerCodes.push(lowerCode)
            
            if (lowerCode === 32) {
                containsSpace = true
                continue
            }
            
            let bit
            if (lowerCode >= 97 && lowerCode <= 122) {
                bit = lowerCode - 97 // alphabet
            } else if (lowerCode >= 48 && lowerCode <= 57) {
                bit = 26 // numbers
            } else if (lowerCode <= 127) {
                bit = 30 // other ascii
            } else {
                bit = 31 // other utf8
            }
            
            bitflags |= 1 << bit
        }
        
        return {
            lower: lower,
            lowerCodes: lowerCodes,
            bitflags: bitflags,
            containsSpace: containsSpace
        }
    }
    
    /**
     * Remove accents from string
     * @param str - The string to process
     * @returns String without accents
     */
    function removeAccents(str) {
        return str.replace(/\p{Script=Latin}+/gu, match => 
            match.normalize('NFD')
        ).replace(/[\u0300-\u036f]/g, '')
    }
    
    /**
     * Get value from object using dot notation or function
     * @param obj - The object
     * @param prop - The property path or function
     * @returns The value
     */
    function getValue(obj, prop) {
        if (typeof prop === 'function') {
            return prop(obj)
        }
        
        if (typeof prop === 'string') {
            const segs = prop.split('.')
            let result = obj
            for (let i = 0; i < segs.length && result; ++i) {
                result = result[segs[i]]
            }
            return result
        }
        
        return obj[prop]
    }
    
    /**
     * Core fuzzy matching algorithm
     * @param preparedSearch - Prepared search object
     * @param preparedTarget - Prepared target object
     * @returns Result object or null
     */
    function algorithm(preparedSearch, preparedTarget) {
        const searchLowerCodes = preparedSearch.searchLowerCodes
        const targetLowerCodes = preparedTarget.targetLowerCodes
        const searchLen = searchLowerCodes.length
        const targetLen = targetLowerCodes.length
        
        if (searchLen > targetLen) return null
        
        const indexes = []
        let searchIndex = 0
        let targetIndex = 0
        let score = 0
        let consecutiveBonus = 0
        
        while (searchIndex < searchLen && targetIndex < targetLen) {
            const searchCode = searchLowerCodes[searchIndex]
            const targetCode = targetLowerCodes[targetIndex]
            
            if (searchCode === targetCode) {
                indexes.push(targetIndex)
                searchIndex++
                
                // Consecutive character bonus
                if (searchIndex > 0 && targetIndex > indexes[searchIndex - 2] + 1) {
                    consecutiveBonus += 10
                }
                
                // Beginning of word bonus
                if (targetIndex === 0 || targetLowerCodes[targetIndex - 1] === 32) {
                    score += 10
                }
                
                // Uppercase bonus
                if (preparedTarget.target.charCodeAt(targetIndex) >= 65 && 
                    preparedTarget.target.charCodeAt(targetIndex) <= 90) {
                    score += 5
                }
                
                score += 1
            }
            
            targetIndex++
        }
        
        if (searchIndex < searchLen) return null
        
        score += consecutiveBonus
        
        // Penalty for distance between matches
        for (let i = 1; i < indexes.length; ++i) {
            const distance = indexes[i] - indexes[i - 1]
            if (distance > 1) {
                score -= distance * 0.1
            }
        }
        
        return {
            target: preparedTarget.target,
            indexes: indexes,
            score: score
        }
    }
    
    /**
     * Clear all caches
     */
    function cleanup() {
        preparedCache = {}
        preparedSearchCache = {}
    }
    
    /**
     * Find best matching desktop entry for an appId
     * @param appId - The application ID
     * @returns Best matching desktop entry or null
     */
    function findBestDesktopEntry(appId) {
        try {
            if (typeof DesktopEntries !== 'undefined' && DesktopEntries.applications) {
                const model = DesktopEntries.applications
                const targets = []
                
                // Build targets array from desktop entries
                for (let i = 0; i < model.count; i++) {
                    const app = model.get(i)
                    if (app.name) {
                        targets.push({
                            name: app.name,
                            exec: app.exec || '',
                            icon: app.icon || '',
                            desktopId: app.desktopId || '',
                            categories: app.categories || '',
                            mimeType: app.mimeType || ''
                        })
                    }
                }
                
                // Debug: Log what we're searching for and what we found
                if (appId === 'cursor' || appId === 'equibop') {
                    console.log(`FuzzySearch: Looking for "${appId}"`)
                    console.log(`FuzzySearch: Found ${targets.length} desktop entries`)
                    
                    // Log some potential matches
                    for (let i = 0; i < Math.min(10, targets.length); i++) {
                        const target = targets[i]
                        if (target.name.toLowerCase().includes('cursor') || 
                            target.name.toLowerCase().includes('equibop') ||
                            target.exec.toLowerCase().includes('cursor') ||
                            target.exec.toLowerCase().includes('equibop')) {
                            console.log(`FuzzySearch: Potential match - ${target.name} (exec: ${target.exec}, icon: ${target.icon})`)
                        }
                    }
                }
                
                // Search with multiple keys for best match
                const results = search(appId, targets, {
                    keys: ['name', 'exec', 'desktopId'],
                    threshold: 0.5,
                    limit: 5
                })
                
                if (appId === 'cursor' || appId === 'equibop') {
                    console.log(`FuzzySearch: Search results for "${appId}":`, results.length)
                    for (let i = 0; i < results.length; i++) {
                        console.log(`FuzzySearch: Result ${i}: ${results[i].obj.name} (score: ${results[i].score})`)
                    }
                }
                
                if (results.length > 0) {
                    return results[0].obj
                }
            }
        } catch (e) {
            console.log(`FuzzySearch: Error in findBestDesktopEntry:`, e)
        }
        
        return null
    }
    
    /**
     * Find best matching icon for an appId
     * @param appId - The application ID
     * @returns Best matching icon path or null
     */
    function findBestIcon(appId) {
        const desktopEntry = findBestDesktopEntry(appId)
        if (desktopEntry && desktopEntry.icon) {
            const iconPath = Quickshell.iconPath(desktopEntry.icon, true)
            if (iconPath && iconPath.length > 0) {
                return iconPath
            }
        }
        
        return null
    }
} 
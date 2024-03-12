(* Copyright (c) 2023 Muqiu Han
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright notice,
 *       this list of conditions and the following disclaimer in the documentation
 *       and/or other materials provided with the distribution.
 *     * Neither the name of omtl nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *)

open Color

module type Info_Impl = sig
  val get_info : unit -> string

  val filter : string list -> string list

  val decorate : string list -> string list
end

module type Info_API = sig
  val get : unit -> string
end

module Info_Generator =
functor
  (M : Info_Impl)
  ->
  struct
    let get () : string =
      M.get_info () |> String.split_on_char '\n' |> M.filter |> M.decorate |> String.concat "\n"
  end

module Get_Info = struct
  module Backtrace = struct
    let get_info () = Printexc.get_raw_backtrace () |> Printexc.raw_backtrace_to_string
  end

  module CallStack = struct
    let get_info () = Printexc.get_callstack 20 |> Printexc.raw_backtrace_to_string
  end
end

module Filter = struct
  module Backtrace = struct
    let filter (backtraces : string list) =
      List.filter
        (fun s ->
           (not (String.starts_with ~prefix:"Called from Omtl.test.time" s))
           && not (String.equal s ""))
        backtraces
  end

  module CallStack = struct
    let filter (lst : string list) : string list = lst
  end
end

module Default_decorate = struct
  let decorate (lst : string list) : string list =
    match lst with
    | [] -> []
    | x :: xs ->
        text ~color:First_line (Format.sprintf "| %s" x)
        :: (List.map (fun x -> Format.sprintf "\t\t\t   | %s" x |> text ~color:Second_class_info))
             xs
end

module Backtrace : Info_API = Info_Generator ((
    struct
      include Get_Info.Backtrace
      include Filter.Backtrace
      include Default_decorate
    end :
      Info_Impl))

module CallStack : Info_API = Info_Generator ((
    struct
      include Get_Info.CallStack
      include Filter.CallStack
      include Default_decorate
    end :
      Info_Impl))

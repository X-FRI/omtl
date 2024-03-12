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

type color =
  | Pass
  | Fail
  | Fail_info
  | Time
  | Info_title
  | First_line
  | Dash
  | Suit_name
  | First_class_info
  | Second_class_info

let color_map : (color, string) Hashtbl.t =
  [
    Pass, "\027[32m";
    Fail, "\027[5;31m";
    Fail_info, "\027[31m";
    Info_title, "\027[4;36m";
    Time, "\027[38m";
    First_line, "\027[33m";
    Dash, "\027[35m";
    Suit_name, "\027[1;34m";
    First_class_info, "\027[38m";
    Second_class_info, "\027[37m";
  ]
  |> List.to_seq
  |> Hashtbl.of_seq


(** On Windows platforms, text is returned directly unless force is true *)
let text ~(color : color) ?(force : bool = false) (text : string) =
  if Sys.os_type = "Win32" && not force then
    text
  else
    Format.sprintf "%s%s\027[0m" (Hashtbl.find color_map color) text
